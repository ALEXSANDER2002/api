#!/bin/bash

echo "🔧 Diagnosticando problema da API..."

echo "📡 Verificando se os containers estão rodando..."
docker ps

echo ""
echo "📋 Verificando logs da API..."
docker logs ronda_check_api --tail 20

echo ""
echo "🔍 Testando endpoints diferentes..."

echo "1. Testando / (rota raiz):"
curl -s https://rondacheck.com.br/

echo ""
echo "2. Testando /health (health check):"
curl -s https://rondacheck.com.br/health

echo ""
echo "3. Testando /api-docs (swagger):"
curl -s -I https://rondacheck.com.br/api-docs

echo ""
echo "4. Testando localhost:3000/health:"
curl -s http://localhost:3000/health

echo ""
echo "🔧 Verificando configuração do Nginx..."
docker exec -it ronda_check_api cat /etc/nginx/sites-enabled/default 2>/dev/null || echo "Nginx não está no container da API"

echo ""
echo "📋 Verificando se a API está rodando no container..."
docker exec -it ronda_check_api ps aux | grep node

echo ""
echo "🎯 Se a API não estiver funcionando, vamos reiniciar:"
echo "docker compose down"
echo "docker compose up -d --build" 