# ~/.harbor — what's in there

One-pager for the Harbor AI/tooling ecosystem. Paths below are relative to `~/.harbor`. The full-tree summary (`summary_harbor.md`) uses paths relative to `$HOME` (e.g. `.harbor/agent/...`).

---

## Top-level (dirs and notable files)

| Entry | Purpose |
|-------|---------|
| **agent/** | Agent/task runner (Docker, src: agent.py, chat, tasks: chat_to_goal, direct, plan, refine) |
| **aichat/** | AI chat stack (Dockerfile, start_aichat.sh) |
| **aider/** | Aider integration (start_aider.sh) |
| **airllm/** | AirLLM server (Dockerfile, server.py) |
| **app/** | App assets (woff2 fonts) |
| **bench/** | Benchmarking (Dockerfile) |
| **bionicgpt/** | BionicGPT launcher |
| **bolt/** | Bolt service (Dockerfile) |
| **boost/** | Boost chat/LLM stack (src: chat_node, config, custom_modules, modules, tools) |
| **chatnio/** | ChatNio (Dockerfile, start_chatnio.sh) |
| **chatui/** | Chat UI (start_chatui.sh) |
| **cmdh/** | CMD-H (Dockerfile, harbor.prompt, system.prompt) |
| **comfyui/** | ComfyUI (provisioning.sh) |
| **dify/** | Dify stack (certbot, nginx, openai, ssrf_proxy) |
| **fabric/** | Fabric integration |
| **gptme/** | GPT-Me (toml config) |
| **gum/** | Gum (Dockerfile) |
| **hf/** | Hugging Face (Dockerfile) |
| **hfdownloader/** | HF downloader (Dockerfile) |
| **http-catalog/** | HTTP request catalog (*.http for agent, boost, dify, litellm, ollama, vllm, etc.) |
| **jupyter/** | Jupyter (Dockerfile, workspace notebooks) |
| **ktransformers/** | K-transformers (chat.py, Dockerfile) |
| **latentscope/** | LatentScope (Dockerfile) |
| **librechat/** | LibreChat (start_librechat.sh) |
| **litellm/** | LiteLLM (start_litellm.sh) |
| **llamacpp/** | Llama.cpp (data/templates) |
| **lmeval/** | LM eval (Dockerfile) |
| **mcp/** | MCP (inspector-entrypoint.sh) |
| **mcpo/** | MCPo (start_mcpo.sh) |
| **metamcp/** | Meta MCP (start-sse.mjs) |
| **nexa/** | Nexa (Dockerfile, proxy_server.py) |
| **ol1/** | OL1 app (app.py, Dockerfile) |
| **omnichain/** | Omnichain (prompt, config) |
| **omniparser/** | Omniparser (Dockerfile) |
| **open-webui/** | Open WebUI (extras: artifact, mcts; start_webui.sh) |
| **openinterpreter/** | Open Interpreter (Dockerfile) |
| **oterm/** | Oterm (Dockerfile) |
| **parler/** | Parler (main.py) |
| **parllama/** | Parllama |
| **perplexica/** | Perplexica (source.config.toml) |
| **perplexideez/** | Perplexideez |
| **plandex/** | Plandex (Dockerfile) |
| **profiles/** | Env profiles (default.env) |
| **promptfoo/** | Promptfoo evals (evals/hf) |
| **qrgen/** | QR gen (Dockerfile) |
| **raglite/** | RAG lite (Dockerfile) |
| **repopack/** | Repopack (Dockerfile) |
| **routines/** | Routines (deno.lock) |
| **searxng/** | SearXNG (uwsgi.ini) |
| **shared/** | Shared scripts (harbor_entrypoint.sh, json_config_merger.py, proxy_user.sh, yaml_config_merger.py) |
| **tabbyapi/** | Tabby API (start script) |
| **textgrad/** | TextGrad (Dockerfile, workspace) |
| **txtairag/** | TxtAIRAG (rag.py) |
| **vllm/** | vLLM (Dockerfile) |
| **webtop/** | Webtop (Dockerfile, init scripts) |
| **harbor.sh** | Main Harbor entry script |
| **install.sh**, **setup-harbor.sh**, **setup-harbor-aider.sh** | Install/setup |
| **requirements.sh**, **test-harbor.sh** | Deps and tests |
| **pyproject.toml**, **poetry.lock**, **yarn.lock**, **deno.lock** | Lockfiles |
| **LICENSE** | License |

---

## Quick commands

Run from `~/scripts` (copy each line separately if needed):

```bash
bash home_tree.sh
bash iterm2_tree_summary.sh harbor
cat iterm2_full_trees/summary_harbor.md
```

To open in an editor: `open iterm2_full_trees/summary_harbor.md` or `cursor iterm2_full_trees/summary_harbor.md`.

See **~/scripts/HOME_DIR_AUDIT.md** for how Harbor fits with the rest of `~/`.
