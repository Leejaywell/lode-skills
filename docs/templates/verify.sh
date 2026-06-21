#!/usr/bin/env bash
# 确定性验证脚本 —— 由 lode-build 在开发开始时落到 .lode/<project>/verify.sh。
# 作用：把本项目的「编译 + 全量回归测试」封装成一条命令，全过 exit 0、任一失败非 0。
# Stop 门禁 lode-gate.sh 会实跑它——「编译/测试过没过」是确定性判断，交给程序，不靠模型口头自评。
#
# 绿地：跑编译 + 本项目测试即可。
# 棕地：必须跑【全量既有测试 + 新增测试】，并对比改动前基线——区分「你弄坏的」vs「本来就坏的」。
#       基线在 lode-recon/动手前用 `bash verify.sh > .lode/<project>/baseline.txt 2>&1 || true` 存一次。
#
# 按你的栈替换下面的命令：
set -euo pipefail

# 1) 编译 / 构建
# npm run build

# 2) 全量回归测试（既有 + 新增；棕地尤其不能只跑本 Face 的测试）
# npm test

# 3) 可选：类型检查 / lint（普世不变量，建议也纳入门禁）
# npm run typecheck
# npm run lint

echo "verify.sh: 请把上面的占位命令替换成本项目真实的编译 + 全量测试命令。"
exit 0
