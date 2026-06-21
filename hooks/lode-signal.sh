#!/usr/bin/env bash
# Lodestar 信号采集（UserPromptSubmit hook）。
# 第一性原理：用户纠正即抓成信号，交给自进化。hook 靠关键词只抓"明显的"纠正/不满，
#            漏掉的由主 Agent 自己补记一条（见 CLAUDE.md）。
#
# 行为：从 stdin 读 UserPromptSubmit 的 JSON，取出本轮 prompt 文本；命中纠正/不满关键词，
#       就向最近活跃的 .lode/<project>/signals.jsonl 追加一条信号。永不阻塞用户输入（始终 exit 0）。

set -euo pipefail

INPUT=$(cat 2>/dev/null || true)

# 取 prompt 文本：优先 jq，缺 jq 时退化为整段输入做关键词匹配
if command -v jq >/dev/null 2>&1; then
  PROMPT=$(printf '%s' "${INPUT}" | jq -r '.prompt // .user_prompt // empty' 2>/dev/null || true)
fi
[ -z "${PROMPT:-}" ] && PROMPT="${INPUT}"

# 纠正/不满关键词（中英）。只抓明显的，避免噪声。
KEYWORDS='不对|错了|别这样|不要这样|重来|你理解错|不是这个意思|说过|又错|don'"'"'t do|wrong|that'"'"'s not|stop doing|redo|misunderstood'

echo "${PROMPT}" | grep -qiE "${KEYWORDS}" || exit 0

# 找最近活跃的 lode 工作区
LODE_DIR=$(ls -dt .lode/*/ 2>/dev/null | head -1 || true)
[ -z "${LODE_DIR}" ] && exit 0

SIGNALS="${LODE_DIR}signals.jsonl"

# 时间戳（hook 在真实 shell 里跑，可用 date）
TS=$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo "")

# 转义为 JSON 字符串值
esc() { printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g' | tr '\n' ' '; }

printf '{"ts":"%s","type":"correction","source":"hook","prompt":"%s"}\n' \
  "${TS}" "$(esc "${PROMPT}")" >> "${SIGNALS}"

# 永不阻塞输入
exit 0
