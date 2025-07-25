#!/bin/bash

echo "🧪 Teste Final da Sincronização"
echo "================================"
echo ""

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"
}

warning() {
    echo -e "${YELLOW}[AVISO] $1${NC}"
}

error() {
    echo -e "${RED}[ERRO] $1${NC}"
}

# Teste 1: Health Check
log "1. Testando health check..."
echo "curl -X GET https://rondacheck.com.br/health"
echo ""
curl -X GET https://rondacheck.com.br/health
echo ""
echo ""

# Teste 2: Sincronização vazia
log "2. Testando sincronização vazia..."
echo "curl -X POST https://rondacheck.com.br/sync \\"
echo "  -H \"Content-Type: application/json\" \\"
echo "  -H \"X-Client-Type: mobile\" \\"
echo "  -d '{\"users\": [], \"inspections\": [], \"photos\": []}'"
echo ""
curl -X POST https://rondacheck.com.br/sync \
  -H "Content-Type: application/json" \
  -H "X-Client-Type: mobile" \
  -d '{"users": [], "inspections": [], "photos": []}'
echo ""
echo ""

# Teste 3: Sincronização com payload real (do log do usuário)
log "3. Testando sincronização com payload real..."
echo "Payload baseado no log do app mobile:"
echo ""

PAYLOAD='{
  "users": [],
  "inspections": [
    {
      "id": "d412f035-b4d3-48bd-9c58-f1b7a696dc58",
      "title": "Inspeção de Sinalização",
      "status": "completed",
      "inspectionType": "sinalizacao",
      "inspectorName": "Alexsander",
      "location": "Teste",
      "inspectionDate": "2025-07-25T22:20:45.488Z",
      "createdAt": "2025-07-25T22:20:45.493Z",
      "updatedAt": "2025-07-25 22:20:50",
      "notes": null,
      "isDeleted": false,
      "isSynced": false,
      "syncedAt": null,
      "serverId": null,
      "userId": "b1e1b9b9-ac5a-481a-ac61-9bc530cddbd1"
    }
  ],
  "photos": []
}'

echo "curl -X POST https://rondacheck.com.br/sync \\"
echo "  -H \"Content-Type: application/json\" \\"
echo "  -H \"X-Client-Type: mobile\" \\"
echo "  --max-time 60 \\"
echo "  -d '$PAYLOAD'"
echo ""

curl -X POST https://rondacheck.com.br/sync \
  -H "Content-Type: application/json" \
  -H "X-Client-Type: mobile" \
  --max-time 60 \
  -d "$PAYLOAD"
echo ""
echo ""

# Teste 4: Verificar logs da API
log "4. Verificando logs da API..."
echo "docker compose logs --tail=20 api_service"
echo ""
docker compose logs --tail=20 api_service
echo ""

log "✅ Teste final concluído!"
echo ""
echo "📱 Se todos os testes passaram, o app mobile deve sincronizar sem problemas!"
echo "🎯 O timeout de 15s não deve mais ocorrer." 