#!/bin/bash

echo "🧪 Testando header Cache-Control no CORS..."

echo ""
echo "📋 1. Testando OPTIONS com Cache-Control..."
curl -X OPTIONS https://rondacheck.com.br/health \
  -H "Origin: http://localhost:3001" \
  -H "Access-Control-Request-Method: GET" \
  -H "Access-Control-Request-Headers: Content-Type, Cache-Control" \
  -v 2>&1 | grep -E "(Access-Control|HTTP|>|<)"

echo ""
echo "📋 2. Testando GET com Cache-Control..."
curl -H "Origin: http://localhost:3001" \
  -H "Cache-Control: no-cache" \
  -v https://rondacheck.com.br/health 2>&1 | grep -E "(Access-Control|HTTP|>|<)"

echo ""
echo "📋 3. Testando POST com Cache-Control..."
curl -X POST https://rondacheck.com.br/auth/login \
  -H "Origin: http://localhost:3001" \
  -H "Content-Type: application/json" \
  -H "Cache-Control: no-cache" \
  -d '{"email":"admin@rondacheck.com.br","password":"admin123"}' \
  -v 2>&1 | grep -E "(Access-Control|HTTP|>|<)"

echo ""
echo "📋 4. Rebuild da API com headers expandidos..."
docker compose down
docker compose up -d --build

echo ""
echo "⏳ Aguardando 15 segundos..."
sleep 15

echo ""
echo "📋 5. Testando após rebuild..."
curl -X OPTIONS https://rondacheck.com.br/health \
  -H "Origin: http://localhost:3001" \
  -H "Access-Control-Request-Method: GET" \
  -H "Access-Control-Request-Headers: Content-Type, Cache-Control" \
  -v 2>&1 | grep -E "(Access-Control|HTTP|>|<)"

echo ""
echo "🎯 INSTRUÇÕES PARA O FRONTEND:"
echo "Agora teste com:"
echo ""
echo "fetch('https://rondacheck.com.br/health', {"
echo "  method: 'GET',"
echo "  mode: 'cors',"
echo "  credentials: 'omit',"
echo "  headers: {"
echo "    'Content-Type': 'application/json',"
echo "    'Cache-Control': 'no-cache'"
echo "  }"
echo "})"
echo ".then(r => r.json())"
echo ".then(console.log)"
echo ".catch(console.error);" 