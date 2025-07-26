#!/bin/bash

echo "🔍 DEBUGANDO ERRO 500 NA API!"

echo ""
echo "📋 1. Verificando logs da API..."
docker logs ronda_check_api --tail 30

echo ""
echo "📋 2. Verificando se a API está rodando..."
docker ps | grep ronda_check_api

echo ""
echo "📋 3. Testando API diretamente (sem Nginx)..."
echo "Testando localhost:3001/health:"
curl -v http://localhost:3001/health 2>&1 | head -20

echo ""
echo "📋 4. Verificando se há erro no código TypeScript..."
docker exec -it ronda_check_api sh -c "
cd /app
echo 'Verificando se há erros de compilação:'
npm run build 2>&1 | head -20
"

echo ""
echo "📋 5. Verificando se o arquivo compilado existe..."
docker exec -it ronda_check_api sh -c "
cd /app
echo 'Verificando arquivos compilados:'
ls -la dist/
"

echo ""
echo "📋 6. Verificando se há problema no server.ts..."
docker exec -it ronda_check_api sh -c "
cd /app
echo 'Verificando server.ts:'
cat src/server.ts
"

echo ""
echo "📋 7. Testando se o problema é no /health endpoint..."
docker exec -it ronda_check_api sh -c "
cd /app
echo 'Verificando se /health está definido:'
grep -n 'health' src/server.ts
"

echo ""
echo "📋 8. Verificando se há problema no Swagger..."
docker exec -it ronda_check_api sh -c "
cd /app
echo 'Verificando configuração Swagger:'
grep -A 10 -B 5 'swagger' src/server.ts
"

echo ""
echo "📋 9. Se tudo falhar, vou reiniciar a API..."
docker compose restart ronda_check_api

echo ""
echo "⏳ Aguardando 30 segundos..."
sleep 30

echo ""
echo "📋 10. Testando após reinicialização..."
curl -v https://rondacheck.com.br/health 2>&1 | head -20

echo ""
echo "🎯 RESULTADO ESPERADO:"
echo "✅ API rodando sem erros"
echo "✅ Status 200 para /health"
echo "✅ Logs sem erros"
echo "✅ Código compilando corretamente"

echo ""
echo "�� DEBUG COMPLETO!" 