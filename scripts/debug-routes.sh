#!/bin/bash

echo "🔍 Debugando rotas da API..."

echo ""
echo "📋 Verificando se o container está rodando..."
docker ps | grep ronda_check_api

echo ""
echo "📋 Verificando logs da API..."
docker logs ronda_check_api --tail 20

echo ""
echo "🔍 Verificando se as rotas estão sendo registradas..."

# Verificar se o endpoint /health está no código compilado
docker exec -it ronda_check_api sh -c "
echo 'Verificando se /health está no código TypeScript...'
grep -n 'app.get.*health' /app/src/app.ts
"

echo ""
echo "🔍 Verificando se o código foi compilado corretamente..."

# Verificar se o arquivo compilado existe
docker exec -it ronda_check_api sh -c "
echo 'Verificando arquivos compilados...'
ls -la /app/dist/
echo ''
echo 'Verificando se app.js existe...'
ls -la /app/dist/app.js
"

echo ""
echo "🔍 Verificando se o servidor está rodando no container..."

# Verificar processos no container
docker exec -it ronda_check_api sh -c "
echo 'Verificando processos Node.js...'
ps aux | grep node
"

echo ""
echo "🔍 Testando endpoints diretamente no container..."

# Testar endpoints diretamente no container
docker exec -it ronda_check_api sh -c "
echo 'Testando localhost:3000/health dentro do container...'
if command -v curl >/dev/null 2>&1; then
    curl -s http://localhost:3000/health
else
    echo 'curl não disponível, tentando com wget...'
    wget -qO- http://localhost:3000/health 2>/dev/null || echo 'wget também não disponível'
fi
"

echo ""
echo "🔍 Verificando configuração do servidor..."

# Verificar arquivo server.ts
docker exec -it ronda_check_api sh -c "
echo 'Verificando server.ts...'
grep -n 'app.listen\|port' /app/src/server.ts
"

echo ""
echo "🔍 Verificando se há erros de compilação..."

# Verificar se há erros no build
docker exec -it ronda_check_api sh -c "
echo 'Verificando logs de build...'
cat /app/npm-debug.log 2>/dev/null || echo 'Nenhum log de debug encontrado'
"

echo ""
echo "🎯 Possíveis soluções:"

echo "1. Se as rotas não estão sendo registradas:"
echo "   - Verificar se o código foi compilado corretamente"
echo "   - Verificar se há erros de TypeScript"

echo ""
echo "2. Se o servidor não está rodando:"
echo "   - Verificar se a porta 3000 está sendo usada"
echo "   - Verificar se há conflitos de porta"

echo ""
echo "3. Se o problema é no Nginx:"
echo "   - Verificar configuração de proxy"
echo "   - Verificar se está redirecionando corretamente"

echo ""
echo "🚀 Tentando solução alternativa..."

# Tentar acessar diretamente a porta 3000
echo "Testando localhost:3000 diretamente:"
curl -s http://localhost:3000/health

echo ""
echo "Testando localhost:3000/ (rota raiz):"
curl -s http://localhost:3000/ 