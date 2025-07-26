#!/bin/bash

echo "🔧 Corrigindo lockfile e CORS..."

echo ""
echo "📋 1. Atualizando lockfile..."
docker exec -it ronda_check_api sh -c "
cd /app
echo 'Atualizando pnpm-lock.yaml...'
pnpm install --no-frozen-lockfile
"

echo ""
echo "📋 2. Verificando se o lockfile foi atualizado..."
docker exec -it ronda_check_api sh -c "
cd /app
echo 'Verificando versões...'
cat package.json | grep '@types/node'
cat pnpm-lock.yaml | grep '@types/node' | head -1
"

echo ""
echo "📋 3. Rebuild da API com lockfile atualizado..."
docker compose down
docker compose up -d --build

echo ""
echo "⏳ Aguardando 20 segundos..."
sleep 20

echo ""
echo "📋 4. Verificando se a API está rodando..."
docker ps | grep ronda_check_api

echo ""
echo "📋 5. Testando CORS após correção..."
echo "Testando OPTIONS request:"
curl -X OPTIONS https://rondacheck.com.br/health \
  -H "Origin: http://localhost:3001" \
  -H "Access-Control-Request-Method: GET" \
  -H "Access-Control-Request-Headers: Content-Type" \
  -v 2>&1 | grep -E "(Access-Control|HTTP)"

echo ""
echo "📋 6. Testando GET request..."
echo "Testando GET request:"
curl -H "Origin: http://localhost:3001" \
  -v https://rondacheck.com.br/health 2>&1 | grep -E "(Access-Control|HTTP)"

echo ""
echo "📋 7. Testando endpoint de login..."
echo "Testando login com CORS:"
curl -X OPTIONS https://rondacheck.com.br/auth/login \
  -H "Origin: http://localhost:3001" \
  -H "Access-Control-Request-Method: POST" \
  -H "Access-Control-Request-Headers: Content-Type" \
  -v 2>&1 | grep -E "(Access-Control|HTTP)"

echo ""
echo "🎯 RESULTADO ESPERADO:"
echo "✅ API deve estar rodando (status 200/204)"
echo "✅ Access-Control-Allow-Origin deve ter apenas UM valor"
echo "✅ Não deve haver erro 502"

echo ""
echo "📋 8. Se ainda houver problemas, tente:"
echo "docker logs ronda_check_api --tail 20" 