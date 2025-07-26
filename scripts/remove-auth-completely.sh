#!/bin/bash

echo "🔓 REMOVENDO AUTENTICAÇÃO COMPLETAMENTE DOS ARQUIVOS COMPILADOS!"

echo ""
echo "📋 1. Parando containers..."
docker compose down

echo ""
echo "📋 2. Removendo middlewares dos arquivos compilados..."
docker run --rm -v $(pwd):/app -w /app node:18 sh -c "
cd /app

echo 'Removendo middlewares dos arquivos compilados...'

# Remover imports e uso de middlewares dos arquivos compilados
sed -i '/require.*authMiddleware/d' dist/routes/*.js
sed -i '/require.*authorizationMiddleware/d' dist/routes/*.js
sed -i '/require.*mobileAuthMiddleware/d' dist/routes/*.js

# Remover chamadas de middlewares das rotas
sed -i '/authMiddleware_1\.authMiddleware/d' dist/routes/*.js
sed -i '/authorizationMiddleware_1\.authorize/d' dist/routes/*.js
sed -i '/mobileAuthMiddleware/d' dist/routes/*.js

# Remover middlewares dos arquivos de rotas
sed -i '/authMiddleware/d' dist/routes/inspectionRoutes.js
sed -i '/authorize/d' dist/routes/inspectionRoutes.js
sed -i '/authMiddleware/d' dist/routes/userRoutes.js
sed -i '/authorize/d' dist/routes/userRoutes.js
sed -i '/authMiddleware/d' dist/routes/photoRoutes.js
sed -i '/authorize/d' dist/routes/photoRoutes.js
sed -i '/authMiddleware/d' dist/routes/syncRoutes.js
sed -i '/authorize/d' dist/routes/syncRoutes.js

echo 'Arquivos compilados limpos!'
"

echo ""
echo "📋 3. Removendo middlewares dos arquivos fonte..."
docker run --rm -v $(pwd):/app -w /app node:18 sh -c "
cd /app

echo 'Removendo middlewares dos arquivos fonte...'

# Remover imports de middlewares
sed -i '/import.*authMiddleware/d' src/routes/*.ts
sed -i '/import.*authorizationMiddleware/d' src/routes/*.ts
sed -i '/import.*mobileAuthMiddleware/d' src/routes/*.ts

# Remover uso de middlewares nas rotas
sed -i '/authMiddleware/d' src/routes/*.ts
sed -i '/authorize/d' src/routes/*.ts
sed -i '/mobileAuthMiddleware/d' src/routes/*.ts

echo 'Arquivos fonte limpos!'
"

echo ""
echo "📋 4. Rebuild completo..."
docker compose up -d --build --force-recreate

echo ""
echo "⏳ Aguardando 60 segundos..."
sleep 60

echo ""
echo "📋 5. Testando endpoints sem autenticação..."
echo "Testando GET /inspections:"
curl -H "Origin: https://exemplo.com" \
  -v https://rondacheck.com.br/inspections 2>&1 | grep -E "(HTTP|Access-Control|{.*})"

echo ""
echo "Testando POST /sync:"
curl -X POST https://rondacheck.com.br/sync \
  -H "Content-Type: application/json" \
  -d '{"users":[],"inspections":[],"photos":[]}' \
  -v 2>&1 | grep -E "(HTTP|Access-Control|{.*})"

echo ""
echo "Testando GET /users:"
curl -H "Origin: https://exemplo.com" \
  -v https://rondacheck.com.br/users 2>&1 | grep -E "(HTTP|Access-Control|{.*})"

echo ""
echo "📋 6. Verificando logs..."
docker logs ronda_check_api --tail 10

echo ""
echo "🎯 RESULTADO ESPERADO:"
echo "✅ Status 200 para todas as requisições"
echo "✅ Sem erro 401 (não autorizado)"
echo "✅ Sem mensagem 'No token provided'"
echo "✅ CORS funcionando"

echo ""
echo "🎉 AUTENTICAÇÃO REMOVIDA COMPLETAMENTE!" 