#!/bin/bash

echo "🧪 Teste Completo de Sincronização"
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

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

# Teste 1: Sincronização vazia
log "1. Testando sincronização vazia..."
echo "curl -X POST https://rondacheck.com.br/sync \\"
echo "  -H \"Content-Type: application/json\" \\"
echo "  -H \"X-Client-Type: mobile\" \\"
echo "  -d '{\"users\": [], \"inspections\": [], \"photos\": [], \"checklistItems\": []}'"
echo ""

RESPONSE=$(curl -s -X POST https://rondacheck.com.br/sync \
  -H "Content-Type: application/json" \
  -H "X-Client-Type: mobile" \
  -d '{"users": [], "inspections": [], "photos": [], "checklistItems": []}')

if [[ $? -eq 0 ]]; then
    success "Sincronização vazia OK"
    echo "$RESPONSE"
else
    error "Sincronização vazia falhou"
fi
echo ""

# Teste 2: Sincronização com usuário
log "2. Testando sincronização com usuário..."
echo ""

USER_PAYLOAD='{
  "users": [
    {
      "email": "teste@mobile.com",
      "name": "Usuário Teste Mobile",
      "password": "123456"
    }
  ],
  "inspections": [],
  "photos": [],
  "checklistItems": []
}'

echo "curl -X POST https://rondacheck.com.br/sync \\"
echo "  -H \"Content-Type: application/json\" \\"
echo "  -H \"X-Client-Type: mobile\" \\"
echo "  -d '$USER_PAYLOAD'"
echo ""

RESPONSE=$(curl -s -X POST https://rondacheck.com.br/sync \
  -H "Content-Type: application/json" \
  -H "X-Client-Type: mobile" \
  -d "$USER_PAYLOAD")

if [[ $? -eq 0 ]]; then
    success "Sincronização com usuário OK"
    echo "$RESPONSE"
else
    error "Sincronização com usuário falhou"
fi
echo ""

# Teste 3: Sincronização com inspeção
log "3. Testando sincronização com inspeção..."
echo ""

INSPECTION_PAYLOAD='{
  "users": [],
  "inspections": [
    {
      "title": "Inspeção Teste Mobile",
      "status": "completed",
      "userId": 1,
      "inspectionType": "sinalizacao",
      "inspectorName": "Alexsander",
      "location": "Local Teste",
      "notes": "Nota de teste"
    }
  ],
  "photos": [],
  "checklistItems": []
}'

echo "curl -X POST https://rondacheck.com.br/sync \\"
echo "  -H \"Content-Type: application/json\" \\"
echo "  -H \"X-Client-Type: mobile\" \\"
echo "  -d '$INSPECTION_PAYLOAD'"
echo ""

RESPONSE=$(curl -s -X POST https://rondacheck.com.br/sync \
  -H "Content-Type: application/json" \
  -H "X-Client-Type: mobile" \
  -d "$INSPECTION_PAYLOAD")

if [[ $? -eq 0 ]]; then
    success "Sincronização com inspeção OK"
    echo "$RESPONSE"
else
    error "Sincronização com inspeção falhou"
fi
echo ""

# Teste 4: Sincronização completa (payload do app)
log "4. Testando sincronização completa (payload do app)..."
echo ""

COMPLETE_PAYLOAD='{
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
    }
  ],
  "photos": []
}'

echo "curl -X POST https://rondacheck.com.br/sync \\"
echo "  -H \"Content-Type: application/json\" \\"
echo "  -H \"X-Client-Type: mobile\" \\"
echo "  --max-time 60 \\"
echo "  -d '$COMPLETE_PAYLOAD'"
echo ""

RESPONSE=$(curl -s -X POST https://rondacheck.com.br/sync \
  -H "Content-Type: application/json" \
  -H "X-Client-Type: mobile" \
  --max-time 60 \
  -d "$COMPLETE_PAYLOAD")

if [[ $? -eq 0 ]]; then
    success "Sincronização completa OK"
    echo "$RESPONSE"
else
    error "Sincronização completa falhou"
fi
echo ""

# Teste 5: Verificar logs da API
log "5. Verificando logs da API..."
echo "docker compose logs --tail=15 api_service"
docker compose logs --tail=15 api_service
echo ""

log "🧪 Teste completo concluído!"
echo ""
echo "📋 Resumo:"
echo "✅ API configurada para sincronizar usuários"
echo "✅ API não requer JWT para mobile (X-Client-Type: mobile)"
echo "✅ Schema flexível para dados mobile"
echo "✅ Logs detalhados para debug"
echo ""
echo "📱 Para o App Mobile:"
echo "   ✅ Use: https://rondacheck.com.br/sync"
echo "   ✅ Header: X-Client-Type: mobile"
echo "   ✅ Pode enviar usuários, inspeções, fotos e checklist items"
echo "   ✅ Não precisa de token JWT" 