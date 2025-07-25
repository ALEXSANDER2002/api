#!/bin/bash

echo "🔧 Corrigindo problema de sincronização..."
echo ""

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERRO] $1${NC}"
}

warning() {
    echo -e "${YELLOW}[AVISO] $1${NC}"
}

log "1. Parando containers..."
docker compose down

log "2. Verificando logs da API..."
docker compose logs --tail=50 api_service

log "3. Rebuild dos containers..."
docker compose build --no-cache

log "4. Iniciando containers..."
docker compose up -d

log "5. Aguardando inicialização..."
sleep 15

log "6. Testando sincronização simples..."
curl -X POST https://rondacheck.com.br/sync \
  -H "Content-Type: application/json" \
  -H "X-Client-Type: mobile" \
  -d '{"users": [], "inspections": [], "photos": []}' \
  -w "\nTempo total: %{time_total}s\n"

echo ""
log "7. Testando com payload real..."
PAYLOAD='{
  "users": [],
  "inspections": [
    {
      "createdAt": "2025-07-25T22:20:45.493Z",
      "id": "d412f035-b4d3-48bd-9c58-f1b7a696dc58",
      "inspectionDate": "2025-07-25T22:20:45.488Z",
      "inspectionType": "sinalizacao",
      "inspectorName": "Alexsander",
      "isDeleted": false,
      "isSynced": false,
      "location": "Teste",
      "notes": null,
      "serverId": null,
      "status": "completed",
      "syncedAt": null,
      "updatedAt": "2025-07-25 22:20:50",
      "userId": "b1e1b9b9-ac5a-481a-ac61-9bc530cddbd1"
    }
  ],
  "photos": []
}'

curl -X POST https://rondacheck.com.br/sync \
  -H "Content-Type: application/json" \
  -H "X-Client-Type: mobile" \
  -d "$PAYLOAD" \
  -w "\nTempo total: %{time_total}s\n" \
  -v

echo ""
log "🔧 Correção concluída!" 