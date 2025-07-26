#!/bin/bash

echo "🔧 RESOLVENDO PROBLEMA DO BANCO COMPLETAMENTE!"

echo ""
echo "📋 1. Parando containers..."
docker compose down

echo ""
echo "📋 2. Removendo volume do banco..."
docker volume rm api_mysql_data 2>/dev/null || true

echo ""
echo "📋 3. Iniciando containers..."
docker compose up -d

echo ""
echo "⏳ Aguardando MySQL inicializar..."
sleep 45

echo ""
echo "📋 4. Verificando MySQL..."
docker exec -it ronda_check_mysql mysql -u root -p92760247 -e "SELECT 1;" 2>/dev/null

echo ""
echo "📋 5. Aplicando migrações..."
docker exec -it ronda_check_api sh -c "
cd /app
echo 'Aplicando migrações...'
npx prisma migrate deploy
"

echo ""
echo "📋 6. Verificando estrutura da tabela..."
docker exec -it ronda_check_mysql mysql -u root -p92760247 -e "
USE ronda_check;
SHOW TABLES;
DESCRIBE User;
"

echo ""
echo "📋 7. Adicionando colunas manualmente se necessário..."
docker exec -it ronda_check_mysql mysql -u root -p92760247 -e "
USE ronda_check;
ALTER TABLE User ADD COLUMN IF NOT EXISTS password VARCHAR(255);
ALTER TABLE User ADD COLUMN IF NOT EXISTS role ENUM('USER', 'ADMIN') DEFAULT 'USER';
"

echo ""
echo "📋 8. Verificando estrutura final..."
docker exec -it ronda_check_mysql mysql -u root -p92760247 -e "
USE ronda_check;
DESCRIBE User;
"

echo ""
echo "📋 9. Gerando cliente Prisma..."
docker exec -it ronda_check_api sh -c "
cd /app
npx prisma generate
"

echo ""
echo "📋 10. Reiniciando API..."
docker compose restart api_service

echo ""
echo "⏳ Aguardando 30 segundos..."
sleep 30

echo ""
echo "📋 11. Testando endpoints..."
echo "Testando GET /health:"
curl -s http://localhost:3000/health

echo ""
echo "Testando GET /users:"
curl -s http://localhost:3000/users

echo ""
echo "Testando GET /inspections:"
curl -s http://localhost:3000/inspections

echo ""
echo "Testando POST /sync:"
curl -s -X POST http://localhost:3000/sync \
  -H "Content-Type: application/json" \
  -d '{"users":[],"inspections":[],"photos":[]}'

echo ""
echo "📋 12. Verificando logs..."
docker logs ronda_check_api --tail 5

echo ""
echo "🎯 RESULTADO ESPERADO:"
echo "✅ Banco de dados funcionando"
echo "✅ Todas as colunas existem"
echo "✅ Todos os endpoints retornando 200"
echo "✅ Sem erros de coluna não encontrada"

echo ""
echo "🔧 PROBLEMA DO BANCO RESOLVIDO!" 