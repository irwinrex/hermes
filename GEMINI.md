# Hermes Agent — Engineering Standards

## Project Vision
- **Privacy First**: Absolute control over data residency.
- **Unified Interface**: A single API surface for all LLMs.
- **Local + Cloud**: Seamless switching between local models and cloud providers.

## Engineering Standards

### 1. Code Quality
- **Surgical Updates**: Prefer precise, context-aware changes.
- **Idiomatic Code**: Follow established patterns and naming conventions.
- **No Suppression**: Never suppress linter warnings or bypass type safety.

### 2. DevOps & Infrastructure
- **IaC First**: All infrastructure defined as code.
- **Resource Constraints**: Always define and respect memory/CPU limits.
- **Statelessness**: Containers should be as stateless as possible.

### 3. QA & Verification (Definition of Done)
- [ ] Implementation satisfies the core requirement.
- [ ] Code is idiomatic and passes linters/type checks.
- [ ] Verification confirms behavioral correctness.
- [ ] No breaking changes introduced.
- [ ] Documentation updated if needed.

## Architecture

- **Hermes Gateway**: Python-based gateway on port `9119`.
- **Local Model Layer**: Ollama on port `11434` for self-hosted models.
- **Cloud Model Layer**: Opencode Zen API for cloud provider access.
- **Control Plane**: Unified `run.sh` script for orchestration across runtimes.

## Key Files
- `run.sh`: Main entry point (Orchestration).
- `docker-compose.yml` / `podman-compose.yml`: Deployment definitions.
- `config/config.yaml`: Hermes agent configuration.
- `config/SOUL.md`: Agent identity and core values.
- `hermes-config/.env.hermes`: API keys and secrets.
