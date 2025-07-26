#!/bin/bash

echo "🔧 Corrigindo CORS para navegador..."

echo ""
echo "📋 1. Verificando se há configuração duplicada no Nginx..."
docker exec -it nginx sh -c "
echo 'Verificando configuração do Nginx...'
cat /etc/nginx/sites-available/default | grep -A 10 -B 10 'location'
"

echo ""
echo "📋 2. Verificando se o Nginx está adicionando headers CORS..."
docker exec -it nginx sh -c "
echo 'Verificando se há add_header no Nginx...'
grep -r 'add_header' /etc/nginx/sites-available/default
"

echo ""
echo "📋 3. Testando diretamente na API (sem Nginx)..."
echo "Testando localhost:3000:"
curl -X OPTIONS http://localhost:3000/health \
  -H "Origin: http://localhost:3001" \
  -H "Access-Control-Request-Method: GET" \
  -H "Access-Control-Request-Headers: Content-Type" \
  -v 2>&1 | grep -E "(Access-Control|HTTP|>|<)"

echo ""
echo "📋 4. Verificando se há middleware duplicado na API..."
docker exec -it ronda_check_api sh -c "
cd /app
echo 'Verificando se há múltiplos app.use(cors)...'
grep -n 'app.use.*cors' /app/dist/app.js
echo ''
echo 'Verificando se há res.setHeader...'
grep -n 'setHeader.*Access-Control' /app/dist/app.js
"

echo ""
echo "📋 5. Corrigindo configuração CORS na API..."
docker exec -it ronda_check_api sh -c "
cd /app
echo 'Verificando configuração atual do CORS...'
grep -A 20 'corsOptions' /app/src/app.ts
"

echo ""
echo "📋 6. Rebuild da API com configuração CORS limpa..."
docker compose down
docker compose up -d --build

echo ""
echo "⏳ Aguardando 15 segundos..."
sleep 15

echo ""
echo "📋 7. Testando CORS após correção..."
echo "Testando OPTIONS via HTTPS:"
curl -X OPTIONS https://rondacheck.com.br/health \
  -H "Origin: http://localhost:3001" \
  -H "Access-Control-Request-Method: GET" \
  -H "Access-Control-Request-Headers: Content-Type" \
  -v 2>&1 | grep -E "(Access-Control|HTTP|>|<)"

echo ""
echo "📋 8. Testando GET request..."
echo "Testando GET via HTTPS:"
curl -H "Origin: http://localhost:3001" \
  -v https://rondacheck.com.br/health 2>&1 | grep -E "(Access-Control|HTTP|>|<)"

echo ""
echo "🎯 INSTRUÇÕES PARA O FRONTEND:"
echo "1. Limpe o cache do navegador (Ctrl+Shift+R)"
echo "2. Abra o DevTools (F12)"
echo "3. Vá na aba Network"
echo "4. Faça a requisição e verifique os headers"
echo "5. Se ainda houver erro, verifique se não há outros middlewares"

echo ""
echo "📋 9. Se o problema persistir, teste:"
echo "fetch('https://rondacheck.com.br/health', {"
echo "  method: 'GET',"
echo "  mode: 'cors',"
echo "  credentials: 'omit',"
echo "  headers: {"
echo "    'Content-Type': 'application/json'"
echo "  }"
echo "})" 