# MEMORY.md — Project History & ADRs

## Architecture Decision Records

### ADR 001: Unified Orchestration via `run.sh`
- **Context**: Users have varied preferences for Docker vs. Podman.
- **Decision**: Implement a unified `run.sh` script that auto-detects the runtime.
- **Impact**: Simplified DX across container engines.

### ADR 002: Dual Model Support (Zen API + Ollama)
- **Context**: Users need both cloud and local model access.
- **Decision**: Support Opencode Zen API for cloud models and Ollama for local models.
- **Impact**: Flexible deployment — offline-capable with cloud fallback.

### ADR 003: Privacy-First (Loopback by Default)
- **Context**: Security of AI interactions is paramount.
- **Decision**: Gateway binds to `127.0.0.1` by default.
- **Impact**: Prevents accidental exposure of the AI gateway.

### ADR 004: Local Config Storage
- **Context**: Multiple Hermes deployments should not share state.
- **Decision**: Store config and data in the project directory (`./config/`, `./.hermes/`).
- **Impact**: Each project is self-contained and portable.
