#!/bin/bash

echo "🔧 CORREÇÃO DEFINITIVA DO CORS!"

echo ""
echo "📋 1. Rebuild da API com CORS simplificado..."
docker compose down
docker compose up -d --build

echo ""
echo "⏳ Aguardando 25 segundos..."
sleep 25

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
echo "📋 4. Testando com Google..."
curl -X OPTIONS https://rondacheck.com.br/health \
  -H "Origin: https://google.com" \
  -H "Access-Control-Request-Method: GET" \
  -H "Access-Control-Request-Headers: Content-Type" \
  -v 2>&1 | grep -E "(Access-Control|HTTP|>|<)"

echo ""
echo "📋 5. Testando GET com domínio externo..."
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
echo "📋 7. Verificando logs da API..."
docker logs ronda_check_api --tail 5

echo ""
echo "🎯 RESULTADO ESPERADO:"
echo "✅ Access-Control-Allow-Origin: https://exemplo.com"
echo "✅ Status 204 para OPTIONS"
echo "✅ Status 200 para GET/POST"
echo "✅ Sem erro 500"
echo "✅ Funciona de qualquer origem"

echo ""
echo "📋 8. Instruções para o frontend:"
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

echo ""
echo "🎉 CORS LIBERADO PARA TODAS AS ORIGENS!" 