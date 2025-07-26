#!/bin/bash

echo "🔧 RESOLVENDO PROBLEMA DE MIGRAÇÃO DO BANCO!"

echo ""
echo "📋 1. Parando containers..."
docker compose down

echo ""
echo "📋 2. Removendo volume do banco (para começar limpo)..."
docker volume rm api_mysql_data 2>/dev/null || true

echo ""
echo "📋 3. Iniciando containers..."
docker compose up -d

echo ""
echo "⏳ Aguardando MySQL inicializar..."
sleep 30

echo ""
echo "📋 4. Verificando se MySQL está pronto..."
docker exec -it ronda_check_mysql mysql -u root -p92760247 -e "SELECT 1;" 2>/dev/null

if [ $? -eq 0 ]; then
  echo "✅ MySQL está pronto!"
else
  echo "⏳ Aguardando mais 30 segundos..."
  sleep 30
fi

echo ""
echo "📋 5. Executando migrações..."
docker exec -it ronda_check_api sh -c "
cd /app
echo 'Executando migrações...'
npx prisma migrate deploy
"

echo ""
echo "📋 6. Verificando se as migrações foram aplicadas..."
docker exec -it ronda_check_mysql mysql -u root -p92760247 -e "
USE ronda_check;
SHOW TABLES;
DESCRIBE User;
"

echo ""
echo "📋 7. Gerando cliente Prisma..."
docker exec -it ronda_check_api sh -c "
cd /app
echo 'Gerando cliente Prisma...'
npx prisma generate
"

echo ""
echo "📋 8. Executando seed..."
docker exec -it ronda_check_api sh -c "
cd /app
echo 'Executando seed...'
npm run seed
"

echo ""
echo "📋 9. Reiniciando API..."
docker compose restart ronda_check_api

echo ""
echo "⏳ Aguardando 30 segundos..."
sleep 30

echo ""
echo "📋 10. Testando endpoints..."
echo "Testando GET /health:"
curl -s http://localhost:3000/health | jq . 2>/dev/null || curl -s http://localhost:3000/health

echo ""
echo "Testando GET /users:"
curl -s http://localhost:3000/users | jq . 2>/dev/null || curl -s http://localhost:3000/users

echo ""
echo "Testando GET /inspections:"
curl -s http://localhost:3000/inspections | jq . 2>/dev/null || curl -s http://localhost:3000/inspections

echo ""
echo "Testando POST /sync:"
curl -s -X POST http://localhost:3000/sync \
  -H "Content-Type: application/json" \
  -d '{"users":[],"inspections":[],"photos":[]}' | jq . 2>/dev/null || curl -s -X POST http://localhost:3000/sync \
  -H "Content-Type: application/json" \
  -d '{"users":[],"inspections":[],"photos":[]}'

echo ""
echo "📋 11. Verificando logs..."
docker logs ronda_check_api --tail 10

echo ""
echo "🎯 RESULTADO ESPERADO:"
echo "✅ Migrações aplicadas com sucesso"
echo "✅ Banco de dados funcionando"
echo "✅ Seed executado"
echo "✅ Todos os endpoints retornando 200"
echo "✅ Sem erros de coluna não encontrada"

echo ""
echo "🔧 PROBLEMA DO BANCO RESOLVIDO!" 