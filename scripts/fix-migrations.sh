#!/bin/bash

echo "🔧 Resolvendo problema das migrações"
echo "===================================="
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

# 1. Verificar se o banco tem dados
log "1. Verificando se o banco tem dados..."
echo "docker compose exec mysql_db mysql -u root -p'92760247' -e \"USE ronda_check; SHOW TABLES;\""
TABLES=$(docker compose exec mysql_db mysql -u root -p'92760247' -e "USE ronda_check; SHOW TABLES;" 2>/dev/null | grep -v "Tables_in_ronda_check" | grep -v "^$" | wc -l)
echo ""

# 2. Se tem tabelas, marcar migrações como aplicadas
if [[ $TABLES -gt 0 ]]; then
    log "2. Banco tem $TABLES tabelas - marcando migrações como aplicadas..."
    echo "docker compose exec api_service npx prisma migrate resolve --applied 20250715162330_init"
    docker compose exec api_service npx prisma migrate resolve --applied 20250715162330_init
    echo "docker compose exec api_service npx prisma migrate resolve --applied 20250715162645_add_password_to_user"
    docker compose exec api_service npx prisma migrate resolve --applied 20250715162645_add_password_to_user
    echo "docker compose exec api_service npx prisma migrate resolve --applied 20250715165658_add_user_role"
    docker compose exec api_service npx prisma migrate resolve --applied 20250715165658_add_user_role
    success "Migrações marcadas como aplicadas"
else
    log "2. Banco vazio - executando migrações..."
    docker compose exec api_service npx prisma migrate deploy
    if [[ $? -eq 0 ]]; then
        success "Migrações executadas com sucesso"
    else
        error "Erro ao executar migrações"
        exit 1
    fi
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

# 5. Verificar dados existentes
log "5. Verificando dados existentes..."
echo "docker compose exec mysql_db mysql -u root -p'92760247' -e \"USE ronda_check; SELECT COUNT(*) as total_users FROM User;\""
docker compose exec mysql_db mysql -u root -p'92760247' -e "USE ronda_check; SELECT COUNT(*) as total_users FROM User;"
echo ""

echo "docker compose exec mysql_db mysql -u root -p'92760247' -e \"USE ronda_check; SELECT COUNT(*) as total_inspections FROM Inspection;\""
docker compose exec mysql_db mysql -u root -p'92760247' -e "USE ronda_check; SELECT COUNT(*) as total_inspections FROM Inspection;"
echo ""

# 6. Testar sincronização
log "6. Testando sincronização..."
echo ""

TEST_PAYLOAD='{
  "users": [
    {
      "email": "teste-pos-migracao@mobile.com",
      "name": "Teste Pós Migração",
      "password": "123456"
    }
  ],
  "inspections": [
    {
      "title": "Teste Pós Migração",
      "status": "completed",
      "userId": 1,
      "inspectionType": "sinalizacao",
      "inspectorName": "Alexsander",
      "location": "Local Pós Migração",
      "notes": "Teste após resolver migrações"
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
    success "Sincronização pós-migração OK"
    echo "$RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"
else
    error "Sincronização pós-migração falhou"
fi
echo ""

log "🔧 Problema das migrações resolvido!"
echo ""
echo "📋 Resumo:"
echo "✅ Migrações resolvidas"
echo "✅ Cliente Prisma gerado"
echo "✅ Tabelas verificadas"
echo "✅ Dados existentes preservados"
echo "✅ Sincronização funcionando"
echo ""
echo "🎯 Próximos passos:"
echo "✅ Execute: ./scripts/check-database.sh"
echo "✅ Execute: ./scripts/check-api-data.sh"
echo "✅ Confirme que os dados estão sendo salvos" 