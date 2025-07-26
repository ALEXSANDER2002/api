#!/bin/bash

echo "🔍 Debugando erro CORS..."

echo ""
echo "📋 1. Verificando logs da API..."
docker logs ronda_check_api --tail 20

echo ""
echo "📋 2. Testando diretamente na API (sem Nginx)..."
echo "Testando localhost:3000 diretamente:"
curl -X OPTIONS http://localhost:3000/health \
  -H "Origin: https://exemplo.com" \
  -H "Access-Control-Request-Method: GET" \
  -H "Access-Control-Request-Headers: Content-Type" \
  -v 2>&1 | grep -E "(Access-Control|HTTP|>|<)"

echo ""
echo "📋 3. Verificando configuração CORS atual..."
docker exec -it ronda_check_api sh -c "
cd /app
echo 'Verificando configuração CORS no código:'
grep -A 10 'corsOptions' /app/src/app.ts
"

echo ""
echo "📋 4. Verificando se há middleware adicional..."
docker exec -it ronda_check_api sh -c "
cd /app
echo 'Verificando middlewares:'
grep -n 'app.use' /app/dist/app.js
"

echo ""
echo "📋 5. Testando com curl simples..."
echo "Testando GET sem Origin:"
curl -v https://rondacheck.com.br/health 2>&1 | grep -E "(HTTP|Access-Control)"

echo ""
echo "📋 6. Verificando se há erro na aplicação..."
docker exec -it ronda_check_api sh -c "
cd /app
echo 'Verificando se a aplicação está rodando:'
ps aux | grep node
echo ''
echo 'Verificando porta 3000:'
netstat -tlnp | grep 3000
"

echo ""
echo "🎯 POSSÍVEIS CAUSAS:"
echo "1. Erro na aplicação quando Origin não é localhost"
echo "2. Middleware CORS não está configurado corretamente"
echo "3. Problema no Nginx"
echo "4. Erro no código da aplicação"

echo ""
echo "📋 7. Testando com diferentes origens..."
echo "Testando com localhost:8080:"
curl -X OPTIONS https://rondacheck.com.br/health \
  -H "Origin: http://localhost:8080" \
  -H "Access-Control-Request-Method: GET" \
  -v 2>&1 | grep -E "(Access-Control|HTTP|>|<)"

echo ""
echo "Testando com 127.0.0.1:3001:"
curl -X OPTIONS https://rondacheck.com.br/health \
  -H "Origin: http://127.0.0.1:3001" \
  -H "Access-Control-Request-Method: GET" \
  -v 2>&1 | grep -E "(Access-Control|HTTP|>|<)" 