#!/bin/bash

echo "🔍 Verificando status real do servidor..."

echo ""
echo "📋 1. Verificando se o container está rodando..."
docker ps | grep ronda_check_api

echo ""
echo "📋 2. Verificando logs da API..."
docker logs ronda_check_api --tail 10

echo ""
echo "📋 3. Verificando se o processo Node.js está rodando..."
docker exec -it ronda_check_api sh -c "
echo 'Processos Node.js:'
ps aux | grep node
echo ''
echo 'Portas em uso:'
netstat -tlnp | grep 3000
"

echo ""
echo "📋 4. Testando conectividade direta..."
echo "Testando localhost:3000 (sem Nginx):"
curl -v http://localhost:3000/ 2>&1 | head -20

echo ""
echo "📋 5. Verificando se o problema é no Nginx..."
echo "Testando se Nginx está redirecionando corretamente:"
curl -v https://rondacheck.com.br/ 2>&1 | head -20

echo ""
echo "📋 6. Verificando configuração do Nginx..."
docker exec -it nginx sh -c "
echo 'Configuração do Nginx:'
cat /etc/nginx/sites-available/default | grep -A 5 -B 5 'location'
"

echo ""
echo "🎯 DIAGNÓSTICO:"
echo "Se localhost:3000 funciona mas HTTPS não, problema é no Nginx"
echo "Se localhost:3000 não funciona, problema é na API"
echo "Se nenhum funciona, problema é no servidor Node.js" 