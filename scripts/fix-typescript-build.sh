#!/bin/bash

echo "🔧 Corrigindo problemas de compilação TypeScript..."

echo ""
echo "📋 1. Verificando se há erros de TypeScript..."
docker exec -it ronda_check_api sh -c "
cd /app
echo 'Verificando erros de TypeScript...'
npx tsc --noEmit
"

echo ""
echo "📋 2. Verificando dependências..."
docker exec -it ronda_check_api sh -c "
cd /app
echo 'Verificando se @types/node está instalado...'
npm list @types/node
echo ''
echo 'Verificando se @types/express está instalado...'
npm list @types/express
"

echo ""
echo "📋 3. Instalando tipos necessários..."
docker exec -it ronda_check_api sh -c "
cd /app
echo 'Instalando @types/node...'
npm install --save-dev @types/node
echo ''
echo 'Instalando @types/express...'
npm install --save-dev @types/express
"

echo ""
echo "📋 4. Limpando e rebuildando..."
docker exec -it ronda_check_api sh -c "
cd /app
echo 'Limpando dist...'
rm -rf dist
echo ''
echo 'Rebuildando...'
npm run build
"

echo ""
echo "📋 5. Verificando se o build foi bem-sucedido..."
docker exec -it ronda_check_api sh -c "
cd /app
echo 'Verificando se server.js foi criado...'
ls -la dist/server.js
echo ''
echo 'Verificando se app.js foi criado...'
ls -la dist/app.js
"

echo ""
echo "📋 6. Reiniciando o servidor..."
docker restart ronda_check_api

echo ""
echo "⏳ Aguardando 10 segundos..."
sleep 10

echo ""
echo "🧪 Testando endpoints..."
echo "Testando /health:"
curl -s http://localhost:3000/health

echo ""
echo "Testando /public/inspections:"
curl -s http://localhost:3000/public/inspections

echo ""
echo "Testando via HTTPS:"
curl -s https://rondacheck.com.br/health 