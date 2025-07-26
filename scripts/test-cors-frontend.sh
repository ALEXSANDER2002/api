#!/bin/bash

echo "🧪 Testando CORS para frontend localhost:3001..."

echo ""
echo "📡 Testando conectividade básica..."

echo "1. Testando health check direto:"
curl -s https://rondacheck.com.br/health

echo ""
echo "2. Testando CORS preflight (OPTIONS):"
curl -s -X OPTIONS https://rondacheck.com.br/health \
  -H "Origin: http://localhost:3001" \
  -H "Access-Control-Request-Method: GET" \
  -H "Access-Control-Request-Headers: Content-Type, Authorization" \
  -v

echo ""
echo "3. Testando requisição com Origin localhost:3001:"
curl -s https://rondacheck.com.br/health \
  -H "Origin: http://localhost:3001" \
  -H "Content-Type: application/json" \
  -v

echo ""
echo "4. Testando requisição com Origin localhost:3001 (sem -s para ver headers):"
curl https://rondacheck.com.br/health \
  -H "Origin: http://localhost:3001" \
  -H "Content-Type: application/json"

echo ""
echo "5. Testando endpoint de inspeções com Origin localhost:3001:"
curl -s https://rondacheck.com.br/public/inspections \
  -H "Origin: http://localhost:3001" \
  -H "Content-Type: application/json"

echo ""
echo "6. Testando login com Origin localhost:3001:"
curl -s -X POST https://rondacheck.com.br/auth/login \
  -H "Origin: http://localhost:3001" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@rondacheck.com.br","password":"admin123"}'

echo ""
echo "🔍 Verificando logs da API..."
docker logs ronda_check_api --tail 10

echo ""
echo "📋 Verificando se a API está rodando..."
docker ps | grep ronda_check_api

echo ""
echo "🎯 Se o problema persistir, execute:"
echo "docker compose restart api_service"
echo ""
echo "📋 Para testar no navegador, abra o console e execute:"
echo "fetch('https://rondacheck.com.br/health', {"
echo "  method: 'GET',"
echo "  headers: {"
echo "    'Content-Type': 'application/json'"
echo "  }"
echo "}).then(r => r.json()).then(console.log).catch(console.error)" 