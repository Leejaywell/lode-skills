#!/usr/bin/env bash
# Lodestar 信号采集（UserPromptSubmit hook）。
# 第一性原理：用户纠正即抓成信号,交给自进化。hook 靠关键词只抓"明显的"纠正/不满,
#            漏掉的由主 Agent 自己补记一条（见 CLAUDE.md）。
#
# 行为：从 stdin 读 UserPromptSubmit 的 JSON,取出本轮 prompt 文本；命中纠正/不满关键词,
#       就向最近活跃的 .lode/<project>/signals.jsonl 追加一条信号。永不阻塞用户输入（始终 exit 0）。
set -euo pipefail

cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || true

INPUT=$(cat 2>/dev/null || true)

# 取 prompt 文本（#8：只匹配解析出的 prompt,不拿整段 JSON 匹配——避免命中字段名/其它字段）。
PROMPT=""
if command -v jq >/dev/null 2>&1; then
  PROMPT=$(printf '%s' "${INPUT}" | jq -r '.prompt // .user_prompt // empty' 2>/dev/null || true)
else
  # 无 jq：尽力抽取 "prompt":"..." 的值;抽不到就放弃匹配（宁可漏,不误报）。
  PROMPT=$(printf '%s' "${INPUT}" \
    | sed -n 's/.*"prompt"[[:space:]]*:[[:space:]]*"\(\([^"\]\|\\.\)*\)".*/\1/p' | head -1 || true)
fi
[ -z "${PROMPT}" ] && exit 0

# 纠正/不满关键词（中英）。收窄到明显信号,去掉过宽词（单独的 wrong/说过等）以降噪。
KEYWORDS='不对|错了|搞错了|你理解错|理解错了|不是这个意思|不要这样|别这样|重来|又错了|不该这么|don'"'"'t do that|that'"'"'s not what|not what i (meant|asked)|stop doing that|redo this|misunderstood'

printf '%s' "${PROMPT}" | grep -qiE "${KEYWORDS}" || exit 0

# 找最近活跃的 lode 工作区
LODE_DIR=$(ls -dt .lode/*/ 2>/dev/null | head -1 || true)
[ -z "${LODE_DIR}" ] && exit 0
SIGNALS="${LODE_DIR}signals.jsonl"

TS=$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo "")

# 转义为 JSON 字符串值
esc() { printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g' | tr '\n' ' '; }

printf '{"ts":"%s","type":"correction","source":"hook","prompt":"%s"}\n' \
  "${TS}" "$(esc "${PROMPT}")" >> "${SIGNALS}" 2>/dev/null || true

exit 0
