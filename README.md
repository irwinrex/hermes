# Hermes Agent — Self-Hosted AI Gateway

Hermes Agent is an autonomous AI agent running locally via Docker/Podman with support for both cloud (Opencode Zen API) and local (Ollama) models.

## Architecture

1. **Hermes Gateway** — WebSocket-based AI orchestration (port 9119)
2. **Hermes Chat** — CLI chat interface inside the container
3. **Ollama** — Local model inference (port 11434) with Gemma 4 8B default

## Quick Start

```bash
# 1. Prepare environment
cp sample.env.hermes hermes-config/.env.hermes
# Edit hermes-config/.env.hermes with your API keys

# 2. Launch services
./run.sh start

# 3. Open dashboard
open http://localhost:9119
```

## Commands

| Command | Action |
|---------|--------|
| `./run.sh start` | Build & Start services |
| `./run.sh status` | Show service health |
| `./run.sh logs` | Aggregated log stream |
| `./run.sh chat` | Open Hermes CLI chat |
| `./run.sh exec <cmd>` | Run command inside container |
| `./run.sh down` | Stop Hermes |
| `./run.sh clean` | Full reset (wipes volumes) |

## Configuration

- `hermes-config/config.yaml` — Hermes agent settings
- `hermes-config/.env.hermes` — API keys and secrets
- `hermes-config/SOUL.md` — Agent personality and directives
- `hermes-config/gemma4-Modelfile` — Local model configuration

Data is stored in `./hermes-data/` (local to this project).
