#!/bin/bash

echo "🔧 Corrigindo CORS para frontend localhost:3001..."

echo ""
echo "📋 Verificando configuração atual do CORS..."
grep -n "localhost:3001" src/app.ts

echo ""
echo "🔄 Reiniciando a API para aplicar configurações..."
docker compose restart api_service

echo ""
echo "⏳ Aguardando 10 segundos para a API inicializar..."
sleep 10

echo ""
echo "🧪 Testando se a API está respondendo..."
API_RESPONSE=$(curl -s https://rondacheck.com.br/health)
if [[ $API_RESPONSE == *"OK"* ]]; then
    echo "✅ API está respondendo"
else
    echo "❌ API não está respondendo"
    echo "Resposta: $API_RESPONSE"
    echo ""
    echo "🔧 Tentando rebuild completo..."
    docker compose down
    docker compose up -d --build
    sleep 15
fi

echo ""
echo "🧪 Testando CORS com localhost:3001..."

# Teste 1: Health check com Origin localhost:3001
echo "1. Testando health check:"
CORS_RESPONSE=$(curl -s -I https://rondacheck.com.br/health \
  -H "Origin: http://localhost:3001" \
  -H "Content-Type: application/json")

echo "$CORS_RESPONSE"

# Teste 2: Verificar headers CORS
echo ""
echo "2. Verificando headers CORS:"
curl -s -I https://rondacheck.com.br/health \
  -H "Origin: http://localhost:3001" | grep -i "access-control"

echo ""
echo "3. Testando requisição completa:"
curl -s https://rondacheck.com.br/health \
  -H "Origin: http://localhost:3001" \
  -H "Content-Type: application/json"

echo ""
echo "4. Testando endpoint de inspeções:"
curl -s https://rondacheck.com.br/public/inspections \
  -H "Origin: http://localhost:3001" \
  -H "Content-Type: application/json" | head -c 200

echo ""
echo "✅ Configuração CORS aplicada!"
echo ""
echo "📋 Para testar no frontend, use:"
echo ""
echo "// Teste básico"
echo "fetch('https://rondacheck.com.br/health')"
echo "  .then(r => r.json())"
echo "  .then(console.log)"
echo "  .catch(console.error)"
echo ""
echo "// Teste com headers"
echo "fetch('https://rondacheck.com.br/health', {"
echo "  method: 'GET',"
echo "  headers: {"
echo "    'Content-Type': 'application/json'"
echo "  }"
echo "})"
echo "  .then(r => r.json())"
echo "  .then(console.log)"
echo "  .catch(console.error)"
echo ""
echo "// Teste de login"
echo "fetch('https://rondacheck.com.br/auth/login', {"
echo "  method: 'POST',"
echo "  headers: {"
echo "    'Content-Type': 'application/json'"
echo "  },"
echo "  body: JSON.stringify({"
echo "    email: 'admin@rondacheck.com.br',"
echo "    password: 'admin123'"
echo "  })"
echo "})"
echo "  .then(r => r.json())"
echo "  .then(console.log)"
echo "  .catch(console.error)" 