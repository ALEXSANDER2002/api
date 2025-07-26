#!/bin/bash

echo "🧪 Testando todos os endpoints da API..."

echo ""
echo "📋 1. Testando endpoint /health (HTTP):"
curl -s http://localhost:3000/health | jq .

echo ""
echo "📋 2. Testando endpoint /health (HTTPS):"
curl -s https://rondacheck.com.br/health | jq .

echo ""
echo "📋 3. Testando endpoint /public/inspections (HTTP):"
curl -s http://localhost:3000/public/inspections | jq .

echo ""
echo "📋 4. Testando endpoint /public/inspections (HTTPS):"
curl -s https://rondacheck.com.br/public/inspections | jq .

echo ""
echo "📋 5. Testando endpoint / (rota raiz):"
curl -s http://localhost:3000/

echo ""
echo "📋 6. Testando CORS para localhost:3001:"
curl -H "Origin: http://localhost:3001" \
     -H "Access-Control-Request-Method: GET" \
     -H "Access-Control-Request-Headers: Content-Type" \
     -X OPTIONS \
     -v https://rondacheck.com.br/health 2>&1 | grep -E "(Access-Control|HTTP)"

echo ""
echo "📋 7. Testando Swagger docs:"
curl -s https://rondacheck.com.br/api-docs | head -10

echo ""
echo "📋 8. Testando Swagger JSON:"
curl -s https://rondacheck.com.br/swagger.json | jq '.info.title'

echo ""
echo "🎯 RESULTADO:"
echo "✅ Se todos os endpoints funcionarem = API 100% operacional"
echo "❌ Se algum falhar = Problema específico identificado" 