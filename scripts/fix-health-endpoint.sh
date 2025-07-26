#!/bin/bash

echo "🔧 Corrigindo endpoint /health..."

echo "📋 Verificando se o endpoint /health está sendo registrado..."

# Verificar se o endpoint está sendo registrado corretamente
docker exec -it ronda_check_api sh -c "
echo 'Verificando se o endpoint /health está no código...'
grep -n 'app.get.*health' /app/src/app.ts || echo 'Endpoint /health não encontrado no código'
"

echo ""
echo "🔍 Verificando se há conflitos de rota..."

# Verificar se há outras rotas que podem estar interceptando
docker exec -it ronda_check_api sh -c "
echo 'Verificando todas as rotas registradas...'
grep -n 'app.get\|app.post\|app.use' /app/src/app.ts
"

echo ""
echo "📡 Testando endpoint diretamente no container..."

# Testar o endpoint diretamente no container
docker exec -it ronda_check_api sh -c "
echo 'Testando localhost:3000/health dentro do container...'
curl -s http://localhost:3000/health
"

echo ""
echo "🔧 Verificando se o problema é no Nginx..."

# Verificar configuração do Nginx
echo "Verificando configuração do Nginx..."
sudo nginx -t

echo ""
echo "📋 Verificando logs do Nginx..."
sudo tail -n 10 /var/log/nginx/error.log

echo ""
echo "🎯 Soluções possíveis:"

echo "1. Se o endpoint não estiver sendo registrado:"
echo "   - Verificar se o código foi compilado corretamente"
echo "   - Rebuild do container"

echo ""
echo "2. Se for problema do Nginx:"
echo "   - Verificar configuração de proxy"
echo "   - Verificar se está redirecionando corretamente"

echo ""
echo "3. Se for problema de rota:"
echo "   - Verificar se há conflitos de middleware"
echo "   - Verificar ordem das rotas"

echo ""
echo "🚀 Tentando reiniciar a API..."
docker compose restart api_service

echo ""
echo "⏳ Aguardando 5 segundos..."
sleep 5

echo ""
echo "🧪 Testando novamente..."
curl -s https://rondacheck.com.br/health 