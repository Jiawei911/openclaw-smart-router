#!/bin/bash
# sclaw.sh v3.0 - Zero-Restart, Zero-Config-Mutation, Zero-Conflict
# The ultimate Smart OpenClaw wrapper
#
# Usage:
#   sclaw.sh "Your task here"              (Auto-detect)
#   sclaw.sh -m deepseek "Your task here"  (Manual override)

# --- Configuration ---
# Path to your openclaw.json
CONFIG_SRC="$HOME/.openclaw/openclaw.json"
CACHE_DIR="$HOME/.cache/sclaw"
mkdir -p "$CACHE_DIR"

# OpenClaw Executable
# Try to find 'openclaw' in PATH, fallback to typical locations or define your own
if command -v openclaw &> /dev/null; then
    OPENCLAW_BIN="openclaw"
elif [ -f "/opt/homebrew/bin/openclaw" ]; then
    OPENCLAW_BIN="/opt/homebrew/bin/openclaw"
else
    # Fallback to direct node execution if you are running from source
    # Change this to point to your openclaw/dist/index.js if needed
    # Example: OPENCLAW_BIN="node $HOME/openclaw/dist/index.js"
    echo "❌ Error: 'openclaw' command not found. Please edit this script to set OPENCLAW_BIN."
    exit 1
fi

# --- Main Logic ---

# Temporary Environment Setup
SESSION_ID=$$
TEMP_CONFIG_DIR="/tmp/sclaw_$SESSION_ID"
TEMP_CONFIG_FILE="$TEMP_CONFIG_DIR/openclaw.json"

# Cleanup on exit
trap "rm -rf '$TEMP_CONFIG_DIR'" EXIT

mkdir -p "$TEMP_CONFIG_DIR"
if [ ! -f "$CONFIG_SRC" ]; then
    echo "❌ Error: Config file not found at $CONFIG_SRC"
    exit 1
fi
cp "$CONFIG_SRC" "$TEMP_CONFIG_FILE"

QUERY=""
MANUAL_MODEL=""

# 0. Parse Arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -m|--model) MANUAL_MODEL="$2"; shift ;;
        *) QUERY="$1" ;;
    esac
    shift
done

if [ -z "$QUERY" ]; then
    echo "Usage: sclaw [-m model] \"Task\""
    exit 1
fi

# Edit these model IDs to match your openclaw.json providers
get_model_id() {
    case "$1" in
        DEEPSEEK) echo "nvidia-deepseek/deepseek-ai/deepseek-v3.2" ;;
        MINIMAX)  echo "minimax-portal/MiniMax-M2.1" ;;
        QWEN_MAX) echo "aliyun-dashscope/qwen-max" ;;
        QWEN_FLASH) echo "aliyun-dashscope/qwen-flash" ;;
        GLM)      echo "xfyun-glm/xopglm47blth2" ;;
        # Default fallback
        *)        echo "aliyun-dashscope/qwen-max" ;; 
    esac
}

# Python Classifier (embedded)
classify_task() {
    python3 -c "
import sys
task = sys.argv[1].lower()
keywords = {
    'CODING': ['code', 'python', 'script', 'function', 'bug', 'error', 'program', 'react', 'js', 'html', 'css', 'api', 'json', 'yaml', 'docker', 'algorithm', 'class', 'method'],
    'CREATIVE': ['story', 'poem', 'novel', 'joke', 'roleplay', 'scenario', 'imagine', 'write a', 'creative', 'song', 'lyrics'],
    'REASONING': ['math', 'logic', 'analyze', 'plan', 'strategy', 'step by step', 'solve', 'calculate', 'why', 'how to', 'reason'],
    'SIMPLE': ['hello', 'hi', 'translate', 'what is', 'define', 'meaning', 'summary', 'short', 'weather', 'time']
}
score = {'CODING': 0, 'CREATIVE': 0, 'REASONING': 0, 'SIMPLE': 0}
for category, words in keywords.items():
    for word in words:
        if word in task:
            score[category] += 1
# Default logic
best_cat = 'REASONING'
max_score = 0
for cat, s in score.items():
    if s > max_score:
        max_score = s
        best_cat = cat
    elif s == max_score and cat == 'CODING':
        best_cat = cat
print(best_cat)
" "$1"
}

# 1. Classification & Model Selection
if [ -n "$MANUAL_MODEL" ]; then
    case $(echo "$MANUAL_MODEL" | tr '[:upper:]' '[:lower:]') in
        *deepseek*) TARGET_MODEL=$(get_model_id DEEPSEEK) ;;
        *minimax*)  TARGET_MODEL=$(get_model_id MINIMAX) ;;
        *flash*)    TARGET_MODEL=$(get_model_id QWEN_FLASH) ;;
        *glm*)      TARGET_MODEL=$(get_model_id GLM) ;;
        *)          TARGET_MODEL=$(get_model_id QWEN_MAX) ;;
    esac
    REASON="Manual Override"
else
    # Check Cache
    QUERY_HASH=$(python3 -c "import hashlib; print(hashlib.md5('''$QUERY'''.encode()).hexdigest())")
    CACHE_FILE="$CACHE_DIR/$QUERY_HASH"
    
    if [ -f "$CACHE_FILE" ]; then
        CATEGORY=$(cat "$CACHE_FILE")
        REASON="Cache Hit ($CATEGORY)"
    else
        # Show only minimal loading indicator
        echo "🤔 Classifying..."
        CATEGORY=$(classify_task "$QUERY")
        echo "$CATEGORY" > "$CACHE_FILE"
        REASON="Local Classifier ($CATEGORY)"
    fi
    
    case "$CATEGORY" in
        CODING)    TARGET_MODEL=$(get_model_id DEEPSEEK) ;;
        CREATIVE)  TARGET_MODEL=$(get_model_id MINIMAX) ;;
        SIMPLE)    TARGET_MODEL=$(get_model_id QWEN_FLASH) ;;
        *)         TARGET_MODEL=$(get_model_id QWEN_MAX) ;;
    esac
fi

echo "🎯 Strategy: $REASON"
echo "🤖 Target: $TARGET_MODEL"

# 2. Zero-Restart Configuration
# Modify the TEMPORARY config file only
sed -i '' 's|"primary": "[^"]*"|"primary": "'"$TARGET_MODEL"'"|' "$TEMP_CONFIG_FILE"

# 3. Execution via XDG_CONFIG_HOME override
# This forces OpenClaw CLI to use our temp config
echo "🚀 Running Agent (Zero-Restart Mode)..."

export XDG_CONFIG_HOME="$TEMP_CONFIG_DIR"
$OPENCLAW_BIN agent --agent main --message "$QUERY"
