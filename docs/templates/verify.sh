#!/usr/bin/env bash
# 确定性验证脚本 —— 由 lode-build 在开发开始时落到 .lode/<project>/verify.sh。
# 作用：把本项目的「编译 + 测试」封装成一条命令，全过 exit 0、任一失败非 0。
# Stop 门禁 lode-gate.sh 会实跑它——「编译/测试过没过」是确定性判断，交给程序，不靠模型口头自评。
#
# 按你的栈替换下面的命令。示例（Node/前端工程）：
set -euo pipefail

# 1) 编译 / 构建
# npm run build

# 2) 测试（单元 + 端到端）
# npm test

# 3) 可选：类型检查 / lint
# npm run typecheck
# npm run lint

echo "verify.sh: 请把上面的占位命令替换成本项目真实的编译+测试命令。"
exit 0
