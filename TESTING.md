# TESTING.md — QA & Validation Guide

## Verification Levels

### 1. Smoke Tests (Readiness)
```bash
./run.sh status

# Verify Gateway
curl -f http://localhost:9119
```

### 2. Functional Verification
```bash
# Check container health
docker compose ps

# Test CLI chat
./run.sh chat "Hello, Hermes!"
```

### 3. Integration Testing
```bash
# Test WebSocket connection
wscat -c ws://localhost:9119
```

## Security Auditing

- **Input Validation**: Test with malformed JSON or large payloads.
- **Auth Enforcement**: Ensure requests without valid credentials are rejected.
- **Container Isolation**: Verify containers can't access host filesystem outside volumes.

## Definition of Done (QA Perspective)

A feature is validated only if:
1. It passes all Smoke Tests.
2. It handles Edge Cases (e.g., provider timeout, invalid API key).
3. It does not regress Security.
4. It is documented in the Playbook.
