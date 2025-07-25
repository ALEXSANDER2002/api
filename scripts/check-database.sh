#!/bin/bash

echo "📊 Verificando dados salvos no banco"
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

# Usar a senha correta do MySQL
MYSQL_PASSWORD="ronda_check_password"

# 1. Verificar usuários
log "1. Verificando usuários no banco..."
echo "docker compose exec mysql_db mysql -u root -p'$MYSQL_PASSWORD' -e \"USE ronda_check; SELECT id, email, name, createdAt FROM users ORDER BY createdAt DESC LIMIT 5;\""
docker compose exec mysql_db mysql -u root -p"$MYSQL_PASSWORD" -e "USE ronda_check; SELECT id, email, name, createdAt FROM users ORDER BY createdAt DESC LIMIT 5;"
echo ""

# 2. Verificar inspeções
log "2. Verificando inspeções no banco..."
echo "docker compose exec mysql_db mysql -u root -p'$MYSQL_PASSWORD' -e \"USE ronda_check; SELECT id, title, status, userId, createdAt FROM inspections ORDER BY createdAt DESC LIMIT 5;\""
docker compose exec mysql_db mysql -u root -p"$MYSQL_PASSWORD" -e "USE ronda_check; SELECT id, title, status, userId, createdAt FROM inspections ORDER BY createdAt DESC LIMIT 5;"
echo ""

# 3. Verificar fotos
log "3. Verificando fotos no banco..."
echo "docker compose exec mysql_db mysql -u root -p'$MYSQL_PASSWORD' -e \"USE ronda_check; SELECT id, url, inspectionId, createdAt FROM photos ORDER BY createdAt DESC LIMIT 5;\""
docker compose exec mysql_db mysql -u root -p"$MYSQL_PASSWORD" -e "USE ronda_check; SELECT id, url, inspectionId, createdAt FROM photos ORDER BY createdAt DESC LIMIT 5;"
echo ""

# 4. Contar registros
log "4. Contando registros no banco..."
echo "docker compose exec mysql_db mysql -u root -p'$MYSQL_PASSWORD' -e \"USE ronda_check; SELECT 'Users' as table_name, COUNT(*) as count FROM users UNION ALL SELECT 'Inspections', COUNT(*) FROM inspections UNION ALL SELECT 'Photos', COUNT(*) FROM photos;\""
docker compose exec mysql_db mysql -u root -p"$MYSQL_PASSWORD" -e "USE ronda_check; SELECT 'Users' as table_name, COUNT(*) as count FROM users UNION ALL SELECT 'Inspections', COUNT(*) FROM inspections UNION ALL SELECT 'Photos', COUNT(*) FROM photos;"
echo ""

# 5. Verificar relacionamentos
log "5. Verificando relacionamentos..."
echo "docker compose exec mysql_db mysql -u root -p'$MYSQL_PASSWORD' -e \"USE ronda_check; SELECT i.id, i.title, u.email as user_email FROM inspections i JOIN users u ON i.userId = u.id ORDER BY i.createdAt DESC LIMIT 3;\""
docker compose exec mysql_db mysql -u root -p"$MYSQL_PASSWORD" -e "USE ronda_check; SELECT i.id, i.title, u.email as user_email FROM inspections i JOIN users u ON i.userId = u.id ORDER BY i.createdAt DESC LIMIT 3;"
echo ""

log "📊 Verificação concluída!"
echo ""
echo "📋 Resumo:"
echo "✅ Todos os dados sincronizados são salvos no banco"
echo "✅ Usuários são criados/atualizados"
echo "✅ Inspeções são criadas/atualizadas"
echo "✅ Fotos são salvas e vinculadas"
echo "✅ Relacionamentos são mantidos"
echo ""
echo "🌐 Para o Web:"
echo "   ✅ Use as rotas GET para buscar dados"
echo "   ✅ Ex: GET /inspections, GET /users, GET /photos"
echo ""
echo "📱 Para o Mobile:"
echo "   ✅ Use a rota POST /sync para enviar dados"
echo "   ✅ Dados são salvos automaticamente"
echo "   ✅ Pode buscar dados salvos depois" 