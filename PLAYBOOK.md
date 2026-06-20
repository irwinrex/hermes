# PLAYBOOK.md — Hermes Operational Guide

## Deployment

```bash
cp .env.example .env
# Edit .env with ZEN_API_KEY
./run.sh start
./run.sh status
```

## Core Operations

### Chat
```bash
# Interactive CLI
./run.sh chat

# Or via docker exec
docker compose exec hermes-chat sh -c '. /opt/hermes/.venv/bin/activate && hermes chat'
```

### Logs
```bash
./run.sh logs -f
```

### Config Management
```bash
# Edit config inside container
docker compose exec hermes-chat sh -c '. /opt/hermes/.venv/bin/activate && hermes config edit'

# Or edit config/config.yaml directly
```

### Model Management
```bash
# List available models
docker compose exec hermes-chat sh -c '. /opt/hermes/.venv/bin/activate && hermes model list'
```

## Security

- **Network Isolation**: Gateway binds to `127.0.0.1` by default.
- **Secrets**: API keys stored in `config/.env`, never committed.
- **Least Privilege**: Containers run with `no-new-privileges`.

## Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| `Connection Refused` | Gateway not running | Run `./run.sh status` |
| `401 Unauthorized` | Invalid API key | Check ZEN_API_KEY in config/.env |
| Ollama not responding | Model not pulled | Wait for model download |
