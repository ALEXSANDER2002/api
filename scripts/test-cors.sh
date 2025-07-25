#!/bin/bash

echo "🧪 Testando configuração do CORS..."
echo ""

# URL da API
API_URL="http://localhost:3000"

echo "1. Testando requisição simples (GET /health):"
curl -X GET "$API_URL/health" \
  -H "Origin: http://localhost:3000" \
  -H "Content-Type: application/json" \
  -v

echo ""
echo ""
echo "2. Testando requisição mobile (POST /sync):"
curl -X POST "$API_URL/sync" \
  -H "Origin: http://localhost:3000" \
  -H "Content-Type: application/json" \
  -H "X-Client-Type: mobile" \
  -d '{"users": [], "inspections": [], "photos": []}' \
  -v

echo ""
echo ""
echo "3. Testando requisição sem origin (como app mobile):"
curl -X POST "$API_URL/sync" \
  -H "Content-Type: application/json" \
  -H "X-Client-Type: mobile" \
  -d '{"users": [], "inspections": [], "photos": []}' \
  -v

echo ""
echo ""
echo "4. Testando requisição com origin não permitida:"
curl -X POST "$API_URL/sync" \
  -H "Origin: http://malicious-site.com" \
  -H "Content-Type: application/json" \
  -H "X-Client-Type: mobile" \
  -d '{"users": [], "inspections": [], "photos": []}' \
  -v

echo ""
echo ""
echo "✅ Testes de CORS concluídos!" 