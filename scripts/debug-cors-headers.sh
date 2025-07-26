#!/bin/bash

echo "🔍 Debugando headers CORS..."

echo ""
echo "📋 1. Verificando headers CORS atuais..."
echo "Testando OPTIONS request detalhado:"
curl -X OPTIONS https://rondacheck.com.br/health \
  -H "Origin: http://localhost:3001" \
  -H "Access-Control-Request-Method: GET" \
  -H "Access-Control-Request-Headers: Content-Type" \
  -v 2>&1 | grep -E "(Access-Control|HTTP|>|<)"

echo ""
echo "📋 2. Verificando se há middleware duplicado..."
docker exec -it ronda_check_api sh -c "
cd /app
echo 'Verificando se há múltiplas configurações de CORS...'
grep -n 'cors' /app/dist/app.js
echo ''
echo 'Verificando se há múltiplos app.use...'
grep -n 'app.use' /app/dist/app.js
"

echo ""
echo "📋 3. Verificando configuração do Nginx..."
docker exec -it nginx sh -c "
echo 'Verificando se Nginx está adicionando headers CORS...'
grep -r 'Access-Control' /etc/nginx/
"

echo ""
echo "📋 4. Testando sem Nginx (diretamente na API)..."
echo "Testando localhost:3000 diretamente:"
curl -X OPTIONS http://localhost:3000/health \
  -H "Origin: http://localhost:3001" \
  -H "Access-Control-Request-Method: GET" \
  -H "Access-Control-Request-Headers: Content-Type" \
  -v 2>&1 | grep -E "(Access-Control|HTTP|>|<)"

echo ""
echo "📋 5. Verificando logs da API..."
docker logs ronda_check_api --tail 10

echo ""
echo "🎯 POSSÍVEIS CAUSAS:"
echo "1. Middleware CORS duplicado na API"
echo "2. Nginx adicionando headers CORS"
echo "3. Configuração incorreta no app.ts"
echo "4. Cache do navegador"

echo ""
echo "🚀 SOLUÇÃO TEMPORÁRIA:"
echo "Teste no frontend com:"
echo "fetch('https://rondacheck.com.br/health', {"
echo "  method: 'GET',"
echo "  mode: 'cors',"
echo "  headers: {"
echo "    'Content-Type': 'application/json'"
echo "  }"
echo "})" 