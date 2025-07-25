#!/bin/bash

echo "🔍 Debugando erro de sincronização"
echo "=================================="
echo ""

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERRO] $1${NC}"
}

# Payload exato do app mobile
PAYLOAD='{
  "users": [],
  "inspections": [
    {
      "id": 1,
      "userId": 1,
      "title": "Teste 3",
      "location": "Teste 3",
      "notes": "",
      "status": "completed",
      "inspectionType": "sinalizacao",
      "inspectorName": "Alexsander",
      "inspectionDate": "2025-07-25T22:43:03.047Z",
      "createdAt": "2025-07-25T22:43:03.051Z",
      "updatedAt": "2025-07-25T22:43:07.000Z"
    }
  ],
  "checklistItems": [
    {
      "id": 2,
      "inspectionId": 1,
      "title": "Sinalização correta de todos os equipamentos de combate a incêndio",
      "status": "completed",
      "notes": "",
      "createdAt": "2025-07-25T22:43:03.060Z",
      "updatedAt": "2025-07-25T22:43:07.000Z"
    },
    {
      "id": 3,
      "inspectionId": 1,
      "title": "Verificação de obstruções dos caminhos de fuga",
      "status": "completed",
      "notes": "",
      "createdAt": "2025-07-25T22:43:03.066Z",
      "updatedAt": "2025-07-25T22:43:07.000Z"
    },
    {
      "id": 4,
      "inspectionId": 1,
      "title": "Análise da visibilidade das placas indicativas",
      "status": "completed",
      "notes": "",
      "createdAt": "2025-07-25T22:43:03.070Z",
      "updatedAt": "2025-07-25T22:43:07.000Z"
    },
    {
      "id": 5,
      "inspectionId": 1,
      "title": "Inspeção das condições de conservação das placas",
      "status": "completed",
      "notes": "",
      "createdAt": "2025-07-25T22:43:03.074Z",
      "updatedAt": "2025-07-25T22:43:07.000Z"
    }
  ],
  "photos": []
}'

log "1. Testando com payload exato do app mobile..."
echo "curl -X POST https://rondacheck.com.br/sync \\"
echo "  -H \"Content-Type: application/json\" \\"
echo "  -H \"X-Client-Type: mobile\" \\"
echo "  --max-time 60 \\"
echo "  -d '$PAYLOAD'"
echo ""

RESPONSE=$(curl -s -X POST https://rondacheck.com.br/sync \
  -H "Content-Type: application/json" \
  -H "X-Client-Type: mobile" \
  --max-time 60 \
  -d "$PAYLOAD")

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST https://rondacheck.com.br/sync \
  -H "Content-Type: application/json" \
  -H "X-Client-Type: mobile" \
  --max-time 60 \
  -d "$PAYLOAD")

echo "HTTP Status Code: $HTTP_CODE"
echo "Response: $RESPONSE"
echo ""

log "2. Verificando logs da API..."
echo "docker compose logs --tail=20 api_service"
docker compose logs --tail=20 api_service
echo ""

log "3. Verificando logs do Nginx..."
echo "tail -10 /var/log/nginx/rondacheck.error.log"
tail -10 /var/log/nginx/rondacheck.error.log
echo ""

echo "tail -5 /var/log/nginx/rondacheck.access.log"
tail -5 /var/log/nginx/rondacheck.access.log
echo ""

log "4. Testando com verbose para ver detalhes..."
echo "curl -v -X POST https://rondacheck.com.br/sync \\"
echo "  -H \"Content-Type: application/json\" \\"
echo "  -H \"X-Client-Type: mobile\" \\"
echo "  --max-time 60 \\"
echo "  -d '$PAYLOAD'"
echo ""

curl -v -X POST https://rondacheck.com.br/sync \
  -H "Content-Type: application/json" \
  -H "X-Client-Type: mobile" \
  --max-time 60 \
  -d "$PAYLOAD" 2>&1 | head -30
echo ""

log "🔍 Debug concluído!"
echo ""
echo "📋 Análise:"
echo "1. Payload com IDs numéricos (correto)"
echo "2. HTTP Status Code: $HTTP_CODE"
echo "3. Response: $RESPONSE"
echo ""
echo "🎯 Próximos passos baseados no resultado:"
echo "- Se HTTP 200: Problema no processamento da resposta"
echo "- Se HTTP 400: Problema de validação"
echo "- Se HTTP 500: Erro interno da API" 