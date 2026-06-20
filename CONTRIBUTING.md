# CONTRIBUTING.md — Developer Guide

We welcome contributions to Hermes Agent!

## Local Development Setup

1. **Environment**: Ensure Docker or Podman is installed.
2. **Bootstrap**:
   ```bash
   cp .env.example .env
   # Add your ZEN_API_KEY for testing
   ```
3. **Execution**:
   ```bash
   ./run.sh start
   ```

## Engineering Standards

- **Clean Code**: Follow DRY and KISS principles.
- **Surgical Updates**: Keep changes focused and minimal.
- **Security**: Never introduce code that logs sensitive data.
- **Verification**: Every PR must include verification steps.

## Branching Strategy

- **main**: The stable branch.
- **feature/<name>**: For new features.
- **fix/<name>**: For bug fixes.
- **docs/<name>**: For documentation-only updates.

## Pull Request Process

1. **Verify**: Ensure your changes don't break core functionality.
2. **Document**: Update related docs if your change introduces new operations.
3. **Check DoD**: Ensure your PR meets the Definition of Done.
4. **Submit**: Provide a clear description of your changes.
