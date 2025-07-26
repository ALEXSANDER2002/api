#!/bin/bash

echo "🔍 Verificando configuração CORS do Nginx..."

echo ""
echo "📋 1. Verificando configuração completa do Nginx..."
docker exec -it nginx sh -c "
echo 'Configuração completa do Nginx:'
cat /etc/nginx/sites-available/default
"

echo ""
echo "📋 2. Verificando se há headers CORS no Nginx..."
docker exec -it nginx sh -c "
echo 'Procurando por headers CORS no Nginx:'
grep -r -i 'cors\|access-control' /etc/nginx/sites-available/default
"

echo ""
echo "📋 3. Verificando se há add_header no Nginx..."
docker exec -it nginx sh -c "
echo 'Procurando por add_header no Nginx:'
grep -r 'add_header' /etc/nginx/sites-available/default
"

echo ""
echo "📋 4. Testando se o problema é no Nginx..."
echo "Testando sem Nginx (diretamente na API):"
curl -X OPTIONS http://localhost:3000/health \
  -H "Origin: http://localhost:3001" \
  -H "Access-Control-Request-Method: GET" \
  -H "Access-Control-Request-Headers: Content-Type" \
  -v 2>&1 | grep -E "(Access-Control|HTTP|>|<)"

echo ""
echo "📋 5. Comparando headers com e sem Nginx..."
echo "Headers via Nginx (HTTPS):"
curl -I https://rondacheck.com.br/health 2>&1 | grep -i access-control

echo ""
echo "Headers direto na API (HTTP):"
curl -I http://localhost:3000/health 2>&1 | grep -i access-control

echo ""
echo "🎯 SE O PROBLEMA FOR NO NGINX:"
echo "Remova qualquer configuração CORS do Nginx e deixe apenas a API gerenciar CORS" 