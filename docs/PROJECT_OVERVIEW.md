# Hermes Payment & Remittance Portal — Project Overview

Short, safe summary of the repository suitable for committing to source control.

## Purpose
- Lightweight payment and remittance portal with a Java backend, supporting a client UI and a dashboard.

## Repository layout (high level)
- `server/` — Node.js service, database connection helpers, and environment samples.
- `client/` — Frontend application (build, Dockerfile, and startup scripts).
- `dashboard/` — Management dashboard service and build artifacts.
- `infra/` — Deployment infrastructure (Docker, Kubernetes manifests, Terraform examples).
- `docs/` — Documentation (this file consolidates the important project notes).

## Architecture
- Backend services connect to a MongoDB instance and may be containerized via Docker or deployed with Kubernetes.
- Secrets and credentials are expected to be provided via environment variables or CI/CD secrets (do not commit secrets).

## Running locally (developer notes)
- Use a local MongoDB or Atlas instance for development.
- Provide required environment variables through a local `.env` file (excluded from source control) or via your shell.

Example (local only, never commit):

```
PORT=9292
NODE_ENV=development
MONGODB_USER=hermes_db_user
MONGODB_PASSWORD=replace_with_local_password
MONGODB_CLUSTER=your-cluster.example.net
MONGODB_DATABASE=hermes_payments
```

## Secrets & Security (required practices)
- Never commit real credentials, API keys, private keys, or passwords into the repository.
- Use GitHub Actions repository secrets (Settings → Secrets and variables → Actions) for CI/CD values.
- For any exposed secret found in the repo (local `.env.example` files, editor settings, or docs), rotate the credential immediately and replace the value with a placeholder.
- Add local editor or IDE settings directories (for example `.vscode/`) to `.gitignore` to avoid accidental commits.

## Recommended immediate actions for maintainers
- Remove or sanitize any `.env.example` that contains real credentials; replace with placeholders such as `your_password_here`.
- Rotate any credential that was committed to the repository (treat it as compromised).
- If a secret needs full removal from the Git history, use a history-rewrite tool (BFG or `git filter-repo`) and coordinate with collaborators because this is destructive.

## CI/CD and Deployment
- CI workflows should reference secrets from repository settings rather than hardcoding them in workflow files.
- Terraform/OCI examples in `infra/terraform` expect secrets to come from environment variables or GitHub secrets.

## Where to find source code
- Backend and server code: `server/` and `src/main/java` (within `client/` and `dashboard/` for their respective services).

## Contact & support
- Maintain repository issues for questions about deployment, local setup, or secret rotation.

---
This file intentionally avoids any sensitive values and documents safe practices for handling secrets.
