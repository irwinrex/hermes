# USER.md — Hermes Personas & DX

## User Profiles

### The Privacy Advocate
- **Goal**: Run a private AI assistant without cloud dependencies.
- **Needs**: Simple installation, local model support (Ollama), and a clean UI.

### The Full-Stack Developer
- **Goal**: Integrate AI into applications via a unified API.
- **Needs**: Standardized interface, MCP support, and stable endpoints.

### The SysAdmin / DevOps Engineer
- **Goal**: Deploy a secure, scalable AI gateway for a team.
- **Needs**: Infrastructure-as-Code, resource limits, health checks, and observability.

## Developer Experience

- **Consistent Tooling**: A single `run.sh` script manages the lifecycle across Docker and Podman.
- **Transparent Config**: Environment-based configuration.
- **Standardized API**: Unified model access regardless of provider.
- **Diagnostic-Ready**: Health checks and logging for rapid debugging.
