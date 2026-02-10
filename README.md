# 🧠 Smart OpenClaw Router (sclaw)

An **adaptive model routing script** for [OpenClaw](https://github.com/openclaw/openclaw). It dynamically switches between AI models based on task complexity, optimizing for both performance and cost.

## 🚀 Why "sclaw"?

If you run OpenClaw on limited hardware (e.g., Mac M1 8GB) or want to balance API costs:
- **Coding Tasks** -> Route to **DeepSeek** (Best logic)
- **Creative Writing** -> Route to **MiniMax/Gemini** (Best prose)
- **Complex Reasoning** -> Route to **Qwen-Max/GPT-4** (Best general reasoning)
- **Simple Chats** -> Route to **Qwen-Flash/Llama-8B** (Fastest & Cheapest)

## ✨ Features

- **Zero Restart**: Uses `XDG_CONFIG_HOME` trick to switch config instantly per-request. No gateway restarts needed!
- **Local Classification**: Uses a blazing fast, embedded Python classifier (keywords-based). Zero external API calls for routing.
- **Concurrency Safe**: Each request runs in an isolated process with its own temporary config. No file/session locking issues.
- **Smart Cache**: Caches routing decisions locally to save even more milliseconds.

## 🛠️ Usage

1. **Install OpenClaw** and configure your provider keys (see `config.example.json`).
2. **Download `sclaw.sh`** and make it executable:
   ```bash
   chmod +x sclaw.sh
   ```
3. **Run your tasks**:

   ```bash
   # Auto-detect mode
   ./sclaw.sh "Write a Python script for a snake game"
   # -> Automatically picks DeepSeek (Coding)

   ./sclaw.sh "Hello world"
   # -> Automatically picks Qwen-Flash (Simple)

   # Manual override
   ./sclaw.sh -m minimax "Tell me a bedtime story"
   ```

## ⚙️ Configuration

1. Edit `sclaw.sh` to match your model IDs:
   ```bash
   # Inside get_model_id() function
   DEEPSEEK) echo "nvidia-deepseek/deepseek-ai/deepseek-v3.2" ;;
   MINIMAX)  echo "minimax-portal/MiniMax-M2.1" ;;
   ...
   ```
2. Ideally, create an alias in your `.zshrc`:
   ```bash
   alias sclaw="~/path/to/sclaw.sh"
   ```

## 🧩 Soul Component (Optional)

Add this to your `~/.openclaw/soul.md` to make the AI aware of its dynamic persona:

```markdown
# Adaptive Identity
You are an adaptive AI assistant that dynamically shifts persona based on the active model backend.

- **Coding Mode (DeepSeek/Claude)**: Senior Software Architect. Output strict, high-quality code.
- **Creative Mode (MiniMax/Gemini)**: Creative Writer. Output engaging, nuanced text.
- **Speed Mode (Qwen-Flash/Llama)**: Efficient Assistant. Output concise answers.
```

## License

MIT
