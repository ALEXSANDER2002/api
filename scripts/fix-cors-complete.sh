#!/bin/bash

echo "🔧 Corrigindo CORS completamente..."

echo ""
echo "📋 1. Verificando se há headers CORS no Nginx..."
docker exec -it nginx sh -c "
echo 'Verificando configuração do Nginx:'
grep -r -i 'cors\|access-control' /etc/nginx/sites-available/default
"

echo ""
echo "📋 2. Removendo headers CORS do Nginx se existirem..."
docker exec -it nginx sh -c "
echo 'Backup da configuração atual:'
cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.backup

echo 'Removendo headers CORS do Nginx:'
sed -i '/add_header.*Access-Control/d' /etc/nginx/sites-available/default

echo 'Configuração atualizada:'
cat /etc/nginx/sites-available/default
"

echo ""
echo "📋 3. Recarregando Nginx..."
docker exec -it nginx sh -c "
nginx -t && nginx -s reload
echo 'Nginx recarregado'
"

echo ""
echo "📋 4. Verificando se há middleware duplicado na API..."
docker exec -it ronda_check_api sh -c "
cd /app
echo 'Verificando se há múltiplos app.use(cors)...'
grep -n 'app.use.*cors' /app/dist/app.js
echo ''
echo 'Verificando se há res.setHeader...'
grep -n 'setHeader.*Access-Control' /app/dist/app.js
"

echo ""
echo "📋 5. Rebuild da API..."
docker compose down
docker compose up -d --build

echo ""
echo "⏳ Aguardando 20 segundos..."
sleep 20

echo ""
echo "📋 6. Testando CORS após correção..."
echo "Testando OPTIONS com localhost:3001:"
curl -X OPTIONS https://rondacheck.com.br/health \
  -H "Origin: http://localhost:3001" \
  -H "Access-Control-Request-Method: GET" \
  -H "Access-Control-Request-Headers: Content-Type, Cache-Control" \
  -v 2>&1 | grep -E "(Access-Control|HTTP|>|<)"

echo ""
echo "Testando OPTIONS com domínio externo:"
curl -X OPTIONS https://rondacheck.com.br/health \
  -H "Origin: https://exemplo.com" \
  -H "Access-Control-Request-Method: GET" \
  -H "Access-Control-Request-Headers: Content-Type" \
  -v 2>&1 | grep -E "(Access-Control|HTTP|>|<)"

echo ""
echo "Testando GET request:"
curl -H "Origin: https://exemplo.com" \
  -v https://rondacheck.com.br/health 2>&1 | grep -E "(Access-Control|HTTP|>|<)"

echo ""
echo "🎯 RESULTADO ESPERADO:"
echo "✅ Access-Control-Allow-Origin: * (para todas as origens)"
echo "✅ Sem headers duplicados"
echo "✅ Status 204 para OPTIONS"
echo "✅ Status 200 para GET"

echo ""
echo "📋 7. Se ainda houver problemas, teste:"
echo "docker logs ronda_check_api --tail 10" 