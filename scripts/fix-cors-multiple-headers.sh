#!/bin/bash

echo "🔧 Corrigindo problema de múltiplos headers CORS..."

echo ""
echo "📋 1. Verificando configuração atual do CORS..."
docker exec -it ronda_check_api sh -c "
cd /app
echo 'Verificando se há configurações duplicadas de CORS...'
grep -n 'Access-Control-Allow-Origin' /app/dist/app.js
"

echo ""
echo "📋 2. Testando headers CORS atuais..."
echo "Testando OPTIONS request:"
curl -X OPTIONS https://rondacheck.com.br/health \
  -H "Origin: http://localhost:3001" \
  -H "Access-Control-Request-Method: GET" \
  -H "Access-Control-Request-Headers: Content-Type" \
  -v 2>&1 | grep -E "(Access-Control|HTTP)"

echo ""
echo "📋 3. Rebuild da API com correção CORS..."
docker compose down
docker compose up -d --build

echo ""
echo "⏳ Aguardando 15 segundos..."
sleep 15

echo ""
echo "📋 4. Testando CORS após correção..."
echo "Testando OPTIONS request:"
curl -X OPTIONS https://rondacheck.com.br/health \
  -H "Origin: http://localhost:3001" \
  -H "Access-Control-Request-Method: GET" \
  -H "Access-Control-Request-Headers: Content-Type" \
  -v 2>&1 | grep -E "(Access-Control|HTTP)"

echo ""
echo "📋 5. Testando GET request com Origin..."
echo "Testando GET request:"
curl -H "Origin: http://localhost:3001" \
  -v https://rondacheck.com.br/health 2>&1 | grep -E "(Access-Control|HTTP)"

echo ""
echo "📋 6. Testando endpoint de login..."
echo "Testando login com CORS:"
curl -X OPTIONS https://rondacheck.com.br/auth/login \
  -H "Origin: http://localhost:3001" \
  -H "Access-Control-Request-Method: POST" \
  -H "Access-Control-Request-Headers: Content-Type" \
  -v 2>&1 | grep -E "(Access-Control|HTTP)"

echo ""
echo "🎯 RESULTADO ESPERADO:"
echo "✅ Access-Control-Allow-Origin deve ter apenas UM valor"
echo "✅ Não deve haver múltiplos valores separados por vírgula"
echo "✅ Status HTTP deve ser 204 para OPTIONS"

echo ""
echo "📋 7. Instruções para o frontend:"
echo "Se o problema persistir, teste no frontend:"
echo ""
echo "fetch('https://rondacheck.com.br/health', {"
echo "  method: 'GET',"
echo "  headers: {"
echo "    'Content-Type': 'application/json'"
echo "  }"
echo "})"
echo ".then(r => r.json())"
echo ".then(console.log)"
echo ".catch(console.error);" 