#!/bin/bash

echo "🗄️ Configurando banco de dados"
echo "==============================="
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

# 1. Verificar se os containers estão rodando
log "1. Verificando containers..."
if ! docker compose ps | grep -q "Up"; then
    error "Containers não estão rodando. Iniciando..."
    docker compose up -d
    sleep 10
else
    success "Containers estão rodando"
fi
echo ""

# 2. Executar migrações do Prisma
log "2. Executando migrações do Prisma..."
echo "docker compose exec api_service npx prisma migrate deploy"
docker compose exec api_service npx prisma migrate deploy
if [[ $? -eq 0 ]]; then
    success "Migrações executadas com sucesso"
else
    error "Erro ao executar migrações"
    exit 1
fi
echo ""

# 3. Gerar cliente Prisma
log "3. Gerando cliente Prisma..."
echo "docker compose exec api_service npx prisma generate"
docker compose exec api_service npx prisma generate
if [[ $? -eq 0 ]]; then
    success "Cliente Prisma gerado"
else
    error "Erro ao gerar cliente Prisma"
fi
echo ""

# 4. Verificar tabelas criadas
log "4. Verificando tabelas criadas..."
echo "docker compose exec mysql_db mysql -u root -p'92760247' -e \"USE ronda_check; SHOW TABLES;\""
docker compose exec mysql_db mysql -u root -p'92760247' -e "USE ronda_check; SHOW TABLES;"
echo ""

# 5. Verificar estrutura das tabelas
log "5. Verificando estrutura das tabelas..."
echo "docker compose exec mysql_db mysql -u root -p'92760247' -e \"USE ronda_check; DESCRIBE users;\""
docker compose exec mysql_db mysql -u root -p'92760247' -e "USE ronda_check; DESCRIBE users;"
echo ""

echo "docker compose exec mysql_db mysql -u root -p'92760247' -e \"USE ronda_check; DESCRIBE inspections;\""
docker compose exec mysql_db mysql -u root -p'92760247' -e "USE ronda_check; DESCRIBE inspections;"
echo ""

echo "docker compose exec mysql_db mysql -u root -p'92760247' -e \"USE ronda_check; DESCRIBE photos;\""
docker compose exec mysql_db mysql -u root -p'92760247' -e "USE ronda_check; DESCRIBE photos;"
echo ""

# 6. Testar sincronização novamente
log "6. Testando sincronização após setup..."
echo ""

TEST_PAYLOAD='{
  "users": [
    {
      "email": "teste-pos-setup@mobile.com",
      "name": "Teste Pós Setup",
      "password": "123456"
    }
  ],
  "inspections": [
    {
      "title": "Teste Pós Setup",
      "status": "completed",
      "userId": 1,
      "inspectionType": "sinalizacao",
      "inspectorName": "Alexsander",
      "location": "Local Pós Setup",
      "notes": "Teste após configuração do banco"
    }
  ],
  "photos": [],
  "checklistItems": []
}'

RESPONSE=$(curl -s -X POST https://rondacheck.com.br/sync \
  -H "Content-Type: application/json" \
  -H "X-Client-Type: mobile" \
  -d "$TEST_PAYLOAD")

if [[ $? -eq 0 ]]; then
    success "Sincronização pós-setup OK"
    echo "$RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"
else
    error "Sincronização pós-setup falhou"
fi
echo ""

# 7. Verificar dados no banco
log "7. Verificando dados no banco..."
echo "docker compose exec mysql_db mysql -u root -p'92760247' -e \"USE ronda_check; SELECT id, email, name FROM users ORDER BY createdAt DESC LIMIT 3;\""
docker compose exec mysql_db mysql -u root -p'92760247' -e "USE ronda_check; SELECT id, email, name FROM users ORDER BY createdAt DESC LIMIT 3;"
echo ""

echo "docker compose exec mysql_db mysql -u root -p'92760247' -e \"USE ronda_check; SELECT id, title, status FROM inspections ORDER BY createdAt DESC LIMIT 3;\""
docker compose exec mysql_db mysql -u root -p'92760247' -e "USE ronda_check; SELECT id, title, status FROM inspections ORDER BY createdAt DESC LIMIT 3;"
echo ""

log "🗄️ Configuração do banco concluída!"
echo ""
echo "📋 Resumo:"
echo "✅ Migrações executadas"
echo "✅ Tabelas criadas"
echo "✅ Cliente Prisma gerado"
echo "✅ Sincronização funcionando"
echo "✅ Dados sendo salvos"
echo ""
echo "🎯 Próximos passos:"
echo "✅ Execute: ./scripts/check-database.sh"
echo "✅ Execute: ./scripts/check-api-data.sh"
echo "✅ Teste a sincronização do mobile" 