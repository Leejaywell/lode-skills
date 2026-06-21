#!/usr/bin/env bash
# Lodestar 收工门禁（Stop hook）。
# 第一性原理：能让程序判断的，做成门禁卡死，不靠模型自觉，也不只信模型写的 flag。
#
# 这道门禁有两层，缺一不可：
#   ① 确定性验证（硬）：跑 .lode/<project>/verify.sh（项目级编译+测试脚本），用退出码说话。
#      —— "编译零报错 / 测试全过" 是最确定性的判断，必须由门禁实跑，而不是塞进模型自评的四步审计。
#   ② 审查通过标记（软）：REVIEW_PASSED 存在、且新于最近一次开发(CHANGELOG)。
#      —— 防止「改了没重审就收工」。标记须带可核验内容（被审 Face/commit 标识），不是空 touch。
#
# 规则：只有「开发已经开始」（存在 CHANGELOG.md）的 Lodestar 工作区才拦。
#       spec/design/plan 阶段（还没代码）放行。
#
# 退出码：0 放行；2 阻止收工并把 stderr 反馈给模型继续干活。

set -euo pipefail

# 取最近修改的 lode 工作区（按 mtime，而非字母序）
LODE_DIR=$(ls -dt .lode/*/ 2>/dev/null | head -1 || true)

# 没有 lode 工作区 => 不是 Lodestar 流程，放行
[ -z "${LODE_DIR}" ] && exit 0

CHANGELOG="${LODE_DIR}CHANGELOG.md"
PASS_MARK="${LODE_DIR}REVIEW_PASSED"
VERIFY="${LODE_DIR}verify.sh"

# 开发还没开始（无 CHANGELOG）=> 早期阶段，不拦
[ -f "${CHANGELOG}" ] || exit 0

# ① 确定性验证：有 verify.sh 就实跑，退出码非 0 直接卡死（编译/测试硬门禁）
if [ -f "${VERIFY}" ]; then
  if ! VERIFY_OUT=$(bash "${VERIFY}" 2>&1); then
    echo "[Lodestar 门禁] 阻止收工：确定性验证 ${VERIFY} 失败（编译/测试未过）。" >&2
    echo "--- verify.sh 输出（末尾 40 行）---" >&2
    echo "${VERIFY_OUT}" | tail -40 >&2
    echo "请修复到 verify.sh 退出码为 0 再收工。" >&2
    exit 2
  fi
else
  # 没有 verify.sh：lode-plan/lode-build 应在开发开始时落一个项目级编译+测试脚本。
  echo "[Lodestar 门禁] 阻止收工：开发已开始但缺少确定性验证脚本 ${VERIFY}。" >&2
  echo "请创建 ${VERIFY}（封装本项目的编译+测试命令，全过 exit 0），让编译/测试由门禁实跑而非模型口头自评。" >&2
  exit 2
fi

# ② 审查标记存在
if [ ! -f "${PASS_MARK}" ]; then
  echo "[Lodestar 门禁] 阻止收工：未发现审查通过标记 ${PASS_MARK}。" >&2
  echo "请先用 lode-review 拆独立审查子 Agent 审查本轮变更；通过后写入 ${PASS_MARK}（内容写明被审 Face/commit 标识）再收工。" >&2
  exit 2
fi

# ② 标记不能是空文件（防止 `touch REVIEW_PASSED` 自证空过）
if [ ! -s "${PASS_MARK}" ]; then
  echo "[Lodestar 门禁] 阻止收工：${PASS_MARK} 为空。" >&2
  echo "标记必须写明本轮被审查的 Face/commit 标识（可核验），不接受空 touch。" >&2
  exit 2
fi

# ② 标记比 CHANGELOG 旧 => 有新改动未重新审查
if [ "${CHANGELOG}" -nt "${PASS_MARK}" ]; then
  echo "[Lodestar 门禁] 阻止收工：CHANGELOG 比审查标记新，存在未重新审查的改动。" >&2
  echo "请重新审查后更新 ${PASS_MARK}。" >&2
  exit 2
fi

exit 0
