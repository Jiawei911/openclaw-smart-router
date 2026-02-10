# 🧠 Smart OpenClaw Router (sclaw)

这是一款为 [OpenClaw](https://github.com/openclaw/openclaw) 打造的 **自适应模型路由脚本**。它能根据任务的复杂度动态切换 AI 模型，从而在性能与成本之间取得完美平衡。

## 🚀 为什么选择 "sclaw"?

如果你正在有限的硬件上运行 OpenClaw，或者希望控制 API 成本：
- **💻 编程任务** -> 自动路由至 **DeepSeek** (逻辑最强)
- **🎨 创意写作** -> 自动路由至 **MiniMax/Gemini** (文采最好)
- **🧠 复杂推理** -> 自动路由至 **Qwen-Max/GPT-4** (综合推理强)
- **⚡ 简单闲聊** -> 自动路由至 **Qwen-Flash/Llama-8B** (极速且便宜)

## ✨主要特性

- **零重启 (Zero Restart)**：使用 `XDG_CONFIG_HOME` 技术实现进程级配置隔离，模型切换瞬间完成无需重启网关！
- **本地分类 (Local Classification)**：内置极速 Python 分类器（关键词匹配），无需消耗任何 API 配额即可判断任务类型。
- **并发安全 (Concurrency Safe)**：每个请求都在独立的进程和临时配置中运行，彻底告别文件锁冲突。
- **智能缓存 (Smart Cache)**：本地缓存路由决策，相同的任务直接命中，响应更快。

## 🛠️ 使用方法

1. **安装 OpenClaw** 并参考 `config.example.json` 配置好你的模型 apiKey。
2. **下载 `sclaw.sh`** 并赋予执行权限：
   ```bash
   chmod +x sclaw.sh
   ```
3. **运行任务**：

   ```bash
   # 自动模式 (Auto-detect)
   ./sclaw.sh "帮我写一个 Python 贪吃蛇游戏"
   # -> 自动识别为 CODING，调用 DeepSeek

   ./sclaw.sh "你好，今天天气怎么样"
   # -> 自动识别为 SIMPLE，调用 Qwen-Flash

   # 手动强制模式 (Manual Override)
   ./sclaw.sh -m minimax "给我讲个睡前故事"
   ```

## ⚙️ 配置说明

1. 编辑 `sclaw.sh` 中的 `get_model_id` 函数，确保模型 ID 与你的 `openclaw.json` 一致：
   ```bash
   DEEPSEEK) echo "nvidia-deepseek/deepseek-ai/deepseek-v3.2" ;;
   MINIMAX)  echo "minimax-portal/MiniMax-M2.1" ;;
   ...
   ```
2. 建议在 `.zshrc` 中添加别名方便调用：
   ```bash
   alias sclaw="~/path/to/sclaw.sh"
   ```

## 🧩 灵魂组件 (可选)

在你的 `~/.openclaw/soul.md` 中添加以下内容，让 AI 意识到自己的多重身份：

```markdown
# 自适应身份 (Adaptive Identity)
你是一个具有自适应能力的 AI 助手，会根据当前运行的模型后端调整你的人格。

- **编程模式 (DeepSeek/Claude)**: 高级软件架构师。输出严谨、高质量的代码。
- **创意模式 (MiniMax/Gemini)**: 创意作家。输出生动、富有情感的文字。
- **极速模式 (Qwen-Flash/Llama)**: 高效助手。输出简洁明了的答案。
```

## 协议

MIT
