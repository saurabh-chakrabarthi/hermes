#!/bin/bash
set -euo pipefail

# Deploys or updates the Hermes Payment Portal on a shared OCI VM.
# Assumes this script is executed from the repository root on the remote host.

APP_DIR=${APP_DIR:-$(pwd)}
COMPOSE_FILE=${COMPOSE_FILE:-"$APP_DIR/payment-infra/docker/docker-compose.yml"}
ENV_FILE=${ENV_FILE:-"$APP_DIR/.env"}

echo "[deploy] repository path: $APP_DIR"

if [ ! -f "$COMPOSE_FILE" ]; then
  echo "[deploy] compose file not found at $COMPOSE_FILE" >&2
  exit 1
fi

# Ensure Docker is present
if ! command -v docker >/dev/null 2>&1; then
  echo "[deploy] docker not found, installing"
  sudo apt-get update -y
  sudo apt-get install -y docker.io docker-compose-plugin
  sudo systemctl enable docker
  sudo systemctl start docker
  sudo usermod -aG docker ubuntu
fi

# Record env vars needed by docker compose
cat > "$ENV_FILE" <<EOF
GITHUB_OWNER=${GITHUB_OWNER}
REDIS_URI=redis://redis:6379
REDIS_SERVICE_URL=http://payment-redis-service:8081
NODE_ENV=production
PORT=9292
EOF
chmod 640 "$ENV_FILE"

# Authenticate to GHCR if a token is provided
if [ -n "${GITHUB_TOKEN:-}" ]; then
  echo "$GITHUB_TOKEN" | docker login ghcr.io -u "${GITHUB_OWNER}" --password-stdin
fi

echo "[deploy] pulling latest containers"
docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" pull

echo "[deploy] applying compose stack"
docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -d --remove-orphans

echo "[deploy] deployment complete"
