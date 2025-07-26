#!/bin/bash

echo "🔓 FORÇANDO REBUILD COMPLETO - SEM AUTENTICAÇÃO!"

echo ""
echo "📋 1. Parando todos os containers..."
docker compose down

echo ""
echo "📋 2. Removendo imagens antigas..."
docker rmi ronda_check_api:latest 2>/dev/null || true

echo ""
echo "📋 3. Limpando cache do Docker..."
docker system prune -f

echo ""
echo "📋 4. Aplicando mudanças finais nos controllers..."
docker run --rm -v $(pwd):/app -w /app node:18 sh -c "
cd /app

echo 'Removendo autenticação dos controllers...'

# Remover imports de middlewares dos controllers
sed -i '/import.*authMiddleware/d' src/controllers/inspectionController.ts
sed -i '/import.*authorizationMiddleware/d' src/controllers/inspectionController.ts
sed -i '/import.*mobileAuthMiddleware/d' src/controllers/syncController.ts

# Remover verificações de token dos controllers
sed -i '/req\.user/d' src/controllers/inspectionController.ts
sed -i '/req\.user/d' src/controllers/userController.ts
sed -i '/req\.user/d' src/controllers/photoController.ts

echo 'Controllers limpos!'
"

echo ""
echo "📋 5. Rebuild completo..."
docker compose up -d --build --force-recreate

echo ""
echo "⏳ Aguardando 60 segundos..."
sleep 60

echo ""
echo "📋 6. Testando endpoints sem autenticação..."
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
echo "📋 7. Verificando logs..."
docker logs ronda_check_api --tail 15

echo ""
echo "🎯 RESULTADO ESPERADO:"
echo "✅ Status 200 para todas as requisições"
echo "✅ Sem erro 401 (não autorizado)"
echo "✅ Sem mensagem 'No token provided'"
echo "✅ CORS funcionando"

echo ""
echo "🎉 REBUILD FORÇADO COMPLETO!" 