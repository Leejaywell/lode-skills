#!/usr/bin/env bash
# Lodestar 自进化触发（SessionStart hook）。
# 第一性原理:自进化的入口不该靠模型自觉——开局由程序检查信号队列,有就提示。
# 行为:统计 .lode/signals.jsonl 的待消化信号数,非空就提示去跑 /lode-evolve。永不阻塞(exit 0)。
set -euo pipefail
cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || true
total=0
[ -f .lode/signals.jsonl ] && total=$(grep -c . .lode/signals.jsonl 2>/dev/null || echo 0)
[ "$total" -gt 0 ] && echo "[Lodestar] 有 $total 条待消化的纠正信号 → 运行 /lode-evolve 把它们沉淀成规则（自进化）。"
exit 0
