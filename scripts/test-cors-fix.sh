#!/bin/bash

echo "🔧 Testando correção CORS com origin: true..."

echo ""
echo "📋 1. Rebuild da API com correção..."
docker compose down
docker compose up -d --build

echo ""
echo "⏳ Aguardando 20 segundos..."
sleep 20

echo ""
echo "📋 2. Testando com localhost:3001..."
curl -X OPTIONS https://rondacheck.com.br/health \
  -H "Origin: http://localhost:3001" \
  -H "Access-Control-Request-Method: GET" \
  -H "Access-Control-Request-Headers: Content-Type, Cache-Control" \
  -v 2>&1 | grep -E "(Access-Control|HTTP|>|<)"

echo ""
echo "📋 3. Testando com domínio externo..."
curl -X OPTIONS https://rondacheck.com.br/health \
  -H "Origin: https://exemplo.com" \
  -H "Access-Control-Request-Method: GET" \
  -H "Access-Control-Request-Headers: Content-Type" \
  -v 2>&1 | grep -E "(Access-Control|HTTP|>|<)"

echo ""
echo "📋 4. Testando com outro domínio externo..."
curl -X OPTIONS https://rondacheck.com.br/health \
  -H "Origin: https://google.com" \
  -H "Access-Control-Request-Method: GET" \
  -H "Access-Control-Request-Headers: Content-Type" \
  -v 2>&1 | grep -E "(Access-Control|HTTP|>|<)"

echo ""
echo "📋 5. Testando GET request com domínio externo..."
curl -H "Origin: https://exemplo.com" \
  -v https://rondacheck.com.br/health 2>&1 | grep -E "(Access-Control|HTTP|>|<)"

echo ""
echo "📋 6. Testando login com domínio externo..."
curl -X POST https://rondacheck.com.br/auth/login \
  -H "Origin: https://exemplo.com" \
  -H "Content-Type: application/json" \
  -H "Cache-Control: no-cache" \
  -d '{"email":"admin@rondacheck.com.br","password":"admin123"}' \
  -v 2>&1 | grep -E "(Access-Control|HTTP|>|<)"

echo ""
echo "🎯 RESULTADO ESPERADO:"
echo "✅ Access-Control-Allow-Origin deve ser o domínio específico"
echo "✅ Status 204 para OPTIONS"
echo "✅ Status 200 para GET/POST"
echo "✅ Sem erro 500"

echo ""
echo "📋 7. Instruções para o frontend:"
echo "Agora teste de qualquer origem:"
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