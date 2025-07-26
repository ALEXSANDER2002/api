#!/bin/bash

echo "🔍 INVESTIGAÇÃO PROFUNDA - Por que os endpoints não funcionam?"

echo ""
echo "📋 1. Verificando se o código foi compilado corretamente..."
docker exec -it ronda_check_api sh -c "
echo 'Verificando se server.js foi compilado...'
ls -la /app/dist/server.js
echo ''
echo 'Verificando se o endpoint /health está no server.js compilado...'
grep -n 'health' /app/dist/server.js
"

echo ""
echo "📋 2. Verificando logs da API..."
docker logs ronda_check_api --tail 20

echo ""
echo "📋 3. Verificando se o servidor está realmente rodando..."
docker exec -it ronda_check_api sh -c "
echo 'Verificando processos Node.js...'
ps aux | grep node
echo ''
echo 'Verificando se a porta 3000 está sendo usada...'
netstat -tlnp | grep 3000
"

echo ""
echo "📋 4. Testando diretamente no container..."
docker exec -it ronda_check_api sh -c "
echo 'Testando localhost:3000/health dentro do container...'
if command -v curl >/dev/null 2>&1; then
  curl -s http://localhost:3000/health
elif command -v wget >/dev/null 2>&1; then
  wget -qO- http://localhost:3000/health
else
  echo 'curl e wget não disponíveis'
fi
"

echo ""
echo "📋 5. Verificando se há problemas de importação..."
docker exec -it ronda_check_api sh -c "
echo 'Verificando se app.js existe e tem conteúdo...'
ls -la /app/dist/app.js
echo ''
echo 'Verificando se server.js importa app.js corretamente...'
head -10 /app/dist/server.js
"

echo ""
echo "📋 6. Verificando se há erros de TypeScript..."
docker exec -it ronda_check_api sh -c "
echo 'Verificando se há erros de compilação...'
cd /app && npm run build 2>&1 | head -20
"

echo ""
echo "📋 7. Verificando se o problema é no Nginx..."
echo "Testando diretamente na porta 3000 (sem Nginx):"
curl -s http://localhost:3000/health

echo ""
echo "📋 8. Verificando configuração do Nginx..."
docker exec -it nginx sh -c "
echo 'Verificando configuração do Nginx...'
cat /etc/nginx/sites-available/default | grep -A 10 -B 10 'location'
"

echo ""
echo "🎯 POSSÍVEIS CAUSAS:"
echo "1. Código não foi compilado corretamente"
echo "2. Problema de importação entre app.js e server.js"
echo "3. Servidor não está rodando na porta correta"
echo "4. Nginx não está redirecionando corretamente"
echo "5. Erro de TypeScript impedindo a compilação"

echo ""
echo "🚀 PRÓXIMOS PASSOS:"
echo "1. Verificar se o TypeScript está compilando sem erros"
echo "2. Verificar se o servidor está realmente rodando"
echo "3. Testar diretamente na porta 3000"
echo "4. Verificar configuração do Nginx" 