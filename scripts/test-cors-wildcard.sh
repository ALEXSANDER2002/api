#!/bin/bash

echo "🌐 Testando CORS liberado para todas as origens..."

echo ""
echo "📋 1. Rebuild da API com CORS liberado..."
docker compose down
docker compose up -d --build

echo ""
echo "⏳ Aguardando 15 segundos..."
sleep 15

echo ""
echo "📋 2. Testando com localhost:3001..."
curl -X OPTIONS https://rondacheck.com.br/health \
  -H "Origin: http://localhost:3001" \
  -H "Access-Control-Request-Method: GET" \
  -H "Access-Control-Request-Headers: Content-Type, Cache-Control" \
  -v 2>&1 | grep -E "(Access-Control|HTTP|>|<)"

echo ""
echo "📋 3. Testando com localhost:3000..."
curl -X OPTIONS https://rondacheck.com.br/health \
  -H "Origin: http://localhost:3000" \
  -H "Access-Control-Request-Method: GET" \
  -H "Access-Control-Request-Headers: Content-Type" \
  -v 2>&1 | grep -E "(Access-Control|HTTP|>|<)"

echo ""
echo "📋 4. Testando com localhost:8080..."
curl -X OPTIONS https://rondacheck.com.br/health \
  -H "Origin: http://localhost:8080" \
  -H "Access-Control-Request-Method: GET" \
  -H "Access-Control-Request-Headers: Content-Type" \
  -v 2>&1 | grep -E "(Access-Control|HTTP|>|<)"

echo ""
echo "📋 5. Testando com domínio externo..."
curl -X OPTIONS https://rondacheck.com.br/health \
  -H "Origin: https://exemplo.com" \
  -H "Access-Control-Request-Method: GET" \
  -H "Access-Control-Request-Headers: Content-Type" \
  -v 2>&1 | grep -E "(Access-Control|HTTP|>|<)"

echo ""
echo "📋 6. Testando GET request..."
curl -H "Origin: http://localhost:3001" \
  -v https://rondacheck.com.br/health 2>&1 | grep -E "(Access-Control|HTTP|>|<)"

echo ""
echo "📋 7. Testando login..."
curl -X POST https://rondacheck.com.br/auth/login \
  -H "Origin: http://localhost:3001" \
  -H "Content-Type: application/json" \
  -H "Cache-Control: no-cache" \
  -d '{"email":"admin@rondacheck.com.br","password":"admin123"}' \
  -v 2>&1 | grep -E "(Access-Control|HTTP|>|<)"

echo ""
echo "🎯 RESULTADO ESPERADO:"
echo "✅ Access-Control-Allow-Origin: * (para todas as origens)"
echo "✅ Status 204 para OPTIONS"
echo "✅ Status 200 para GET/POST"
echo "✅ Sem erro CORS no navegador"

echo ""
echo "📋 8. Instruções para o frontend:"
echo "Agora pode usar qualquer origem:"
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