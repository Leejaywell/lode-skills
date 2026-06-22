#!/usr/bin/env bash
# 确定性验证脚本 —— 由 lode-init / lode-build 落到 .lode/<project>/verify.sh。
# 作用：把本项目的「编译 + 全量回归测试」封装成一条命令,全过 exit 0、任一失败非 0。
# Stop 门禁 lode-gate.sh 会实跑它——「编译/测试过没过」是确定性判断,交给程序,不靠模型口头自评。
#
# 从零新建：跑编译 + 本项目测试即可。
# 改现有代码：必须跑【全量既有测试 + 新增测试】,并对比改动前基线——区分「你弄坏的」vs「本来就坏的」。
#       基线在动手前用 `bash verify.sh > .lode/<project>/baseline.md 2>&1 || true` 存一次。
set -euo pipefail

# ── 未配置守卫（别删错）───────────────────────────────────────────────
# 这是骨架:还没填真实命令时,门禁应当卡死,而不是空壳 exit 0 静默放行。
# 填好下面的真实编译/测试命令后,把这一行的 0 改成 1（表示已配置）：
LODE_VERIFY_CONFIGURED=0
if [ "${LODE_VERIFY_CONFIGURED}" != "1" ]; then
  echo "verify.sh 未配置：把下面的占位命令换成本项目真实的编译+全量测试,再把 LODE_VERIFY_CONFIGURED 改成 1。" >&2
  exit 1
fi
# ─────────────────────────────────────────────────────────────────────

# 按你的栈替换下面的命令（删掉 # 并填真实命令）：

# 1) 编译 / 构建
# npm run build

# 2) 全量回归测试（既有 + 新增；改现有代码尤其不能只跑本切片的测试）
# npm test

# 3) 可选：类型检查 / lint（普世不变量,建议也纳入门禁）
# npm run typecheck
# npm run lint
