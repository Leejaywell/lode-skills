#!/usr/bin/env bash
# Lodestar 收工门禁（Stop hook）。
# 第一性原理：能让程序判断的，做成门禁卡死，不靠模型自觉，也不只信模型写的 flag。
#
# 两层硬检查（只拦「开发已开始」=存在 changelog.md 的工作区；spec/plan 阶段放行）：
#   ① 确定性验证：实跑 .lode/<p>/verify.sh（编译+全量测试），退出码说话。
#      —— 指纹未变且上次已绿则跳过重跑（缓存,避免每次 Stop 都全量构建）。
#   ② 审查通过：review-passed 非空，且其中含【当前代码指纹】——防「审完又改」、防空 touch / 伪造。
#
# 子命令：
#   lode-gate.sh fingerprint   打印当前代码指纹（lode-review 把它写进 review-passed）
#
# 退出码：0 放行；2 阻止收工并把 stderr 反馈给模型继续干活。
#   连续阻止 ≥ LODE_GATE_MAX_ATTEMPTS（默认 5）次 → 熔断：放行并交人工，防「昂贵的不完成」。
set -euo pipefail

# 锚定项目根（#7：cwd 不是根时,优先用 Claude 提供的项目目录）
cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || true

# 选可用的 sha256 工具
_sha() { if command -v shasum >/dev/null 2>&1; then shasum -a 256; else sha256sum; fi; }

# 代码指纹：git 项目用 HEAD+暂存+工作区改动（内容级,真准）;
# 非 git 退化为工作区文件的「路径+大小+mtime」哈希（排除 .lode/.git,尽力而为）。
fingerprint() {
  if git rev-parse --git-dir >/dev/null 2>&1; then
    { git rev-parse HEAD 2>/dev/null || true
      git status --porcelain 2>/dev/null || true
      git diff 2>/dev/null || true; } | _sha | awk '{print $1}'
  else
    # 非 git：对工作区文件【内容】做哈希（内容级,不靠 mtime,避免分钟精度漏检）。
    # 排除运行期/构建产物目录,免得 verify 产物每次改指纹（无 .gitignore 意识,只能硬排常见目录）。
    find . -type d \( -name .git -o -name .lode -o -name node_modules -o -name dist -o -name build \
        -o -name target -o -name .next -o -name vendor -o -name __pycache__ \) -prune -o \
      -type f -print0 2>/dev/null \
      | LC_ALL=C sort -z | xargs -0 cat 2>/dev/null | _sha | awk '{print $1}'
  fi
}

# 子命令：打印指纹供 lode-review 写入 review-passed
if [ "${1:-}" = "fingerprint" ]; then fingerprint; exit 0; fi

# 消费 stdin（Stop hook 的 JSON），不阻塞、不依赖
cat >/dev/null 2>&1 || true

# 收集所有「开发已开始」（有 changelog.md）的工作区（#3：遍历,不挑 mtime 最新那个）
shopt -s nullglob 2>/dev/null || true
STARTED=()
for d in .lode/*/; do
  [ -f "${d}changelog.md" ] && STARTED+=("$d")
done
# 没有任何已开发工作区 => 放行（spec/plan 阶段或非 Lodestar 项目）
[ ${#STARTED[@]} -eq 0 ] && exit 0

MAX_ATTEMPTS="${LODE_GATE_MAX_ATTEMPTS:-5}"
ATTEMPTS_FILE=".lode/.gate-attempts"

# 熔断计数（#5）：连续阻止累加,放行时清零
block() {
  local n=0; [ -f "$ATTEMPTS_FILE" ] && n=$(cat "$ATTEMPTS_FILE" 2>/dev/null || echo 0)
  n=$((n + 1)); echo "$n" > "$ATTEMPTS_FILE" 2>/dev/null || true
  if [ "$n" -ge "$MAX_ATTEMPTS" ]; then
    echo "[Lodestar 熔断] 门禁已连续阻止 $n 次仍未过——停止再拦,交给你人工处理。" >&2
    echo "门禁挡「坏的完成」,熔断挡「昂贵的不完成」。请看上面最后一次失败原因后介入。" >&2
    rm -f "$ATTEMPTS_FILE" 2>/dev/null || true
    exit 0
  fi
  exit 2
}
pass() { rm -f "$ATTEMPTS_FILE" 2>/dev/null || true; exit 0; }

FP="$(fingerprint 2>/dev/null || true)"

for LODE_DIR in "${STARTED[@]}"; do
  VERIFY="${LODE_DIR}verify.sh"
  PASS_MARK="${LODE_DIR}review-passed"
  CACHE="${LODE_DIR}.verify-green"

  # ① 确定性验证
  if [ -f "${VERIFY}" ]; then
    if [ -n "${FP}" ] && [ -f "${CACHE}" ] && [ "$(cat "${CACHE}" 2>/dev/null || true)" = "${FP}" ]; then
      :   # 这个代码状态上次已验证通过 => 跳过重跑（#4 缓存）
    elif VERIFY_OUT=$(bash "${VERIFY}" 2>&1); then
      echo "${FP}" > "${CACHE}" 2>/dev/null || true
    else
      echo "[Lodestar 门禁] 阻止收工：${VERIFY} 失败（编译/测试未过）。" >&2
      echo "--- verify.sh 输出（末尾 40 行）---" >&2
      printf '%s\n' "${VERIFY_OUT}" | tail -40 >&2
      block
    fi
  else
    echo "[Lodestar 门禁] 阻止收工：开发已开始但缺少 ${VERIFY}。" >&2
    echo "请创建 ${VERIFY}（封装本项目编译+全量测试,全过 exit 0;骨架见 docs/templates/verify.sh）。" >&2
    block
  fi

  # ② 审查标记非空（#1 之外：空 touch 不算）
  if [ ! -s "${PASS_MARK}" ]; then
    echo "[Lodestar 门禁] 阻止收工：缺少非空的审查标记 ${PASS_MARK}。" >&2
    echo "请用 lode-review 独立审查本轮变更,通过后把结论写入 ${PASS_MARK},并附当前代码指纹这一行：" >&2
    echo "  tree: ${FP}" >&2
    block
  fi

  # ② 标记必须含【当前】代码指纹（#2 防审完又改、#6 防伪造）
  if [ -n "${FP}" ] && ! grep -qF "${FP}" "${PASS_MARK}"; then
    echo "[Lodestar 门禁] 阻止收工：${PASS_MARK} 的代码指纹与当前不一致——代码在审查后又改过,需重新审查。" >&2
    echo "重新审查通过后,把这一行更新进 ${PASS_MARK}：" >&2
    echo "  tree: ${FP}" >&2
    block
  fi
done

pass
