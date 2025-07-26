#!/bin/bash

echo "🔧 CORRIGINDO PROBLEMA 404 DAS ROTAS!"

echo ""
echo "📋 1. Verificando status atual..."
docker ps | grep ronda_check_api

echo ""
echo "📋 2. Verificando se as rotas estão sendo registradas..."
docker exec -it ronda_check_api sh -c "
cd /app
echo 'Verificando app.ts:'
cat src/app.ts

echo ''
echo 'Verificando se as rotas existem:'
ls -la src/routes/

echo ''
echo 'Verificando conteúdo das rotas:'
echo '=== inspectionRoutes ==='
cat src/routes/inspectionRoutes.ts

echo ''
echo '=== userRoutes ==='
cat src/routes/userRoutes.ts

echo ''
echo '=== syncRoutes ==='
cat src/routes/syncRoutes.ts
"

echo ""
echo "📋 3. Verificando se há problema na compilação..."
docker exec -it ronda_check_api sh -c "
cd /app
echo 'Verificando arquivos compilados:'
ls -la dist/routes/

echo ''
echo 'Verificando conteúdo compilado:'
echo '=== inspectionRoutes.js ==='
cat dist/routes/inspectionRoutes.js

echo ''
echo '=== userRoutes.js ==='
cat dist/routes/userRoutes.js

echo ''
echo '=== syncRoutes.js ==='
cat dist/routes/syncRoutes.js
"

echo ""
echo "📋 4. Reconstruindo rotas corretamente..."
docker exec -it ronda_check_api sh -c "
cd /app

echo 'Reconstruindo inspectionRoutes...'
cat > src/routes/inspectionRoutes.ts << 'EOF'
import { Router } from 'express';
import { inspectionController } from '../controllers/inspectionController';

const router = Router();

// TODAS AS ROTAS LIBERADAS - SEM AUTENTICAÇÃO
router.post('/', inspectionController.createInspection);
router.get('/', inspectionController.getAllInspections);
router.get('/public', inspectionController.getAllInspectionsPublic);
router.get('/:id', inspectionController.getInspectionById);
router.put('/:id', inspectionController.updateInspection);
router.delete('/:id', inspectionController.deleteInspection);

export default router;
EOF

echo 'Reconstruindo userRoutes...'
cat > src/routes/userRoutes.ts << 'EOF'
import { Router } from 'express';
import { userController } from '../controllers/userController';

const router = Router();

// TODAS AS ROTAS LIBERADAS - SEM AUTENTICAÇÃO
router.post('/', userController.createUser);
router.get('/', userController.getAllUsers);
router.get('/:id', userController.getUserById);
router.put('/:id', userController.updateUser);
router.delete('/:id', userController.deleteUser);

export default router;
EOF

echo 'Reconstruindo syncRoutes...'
cat > src/routes/syncRoutes.ts << 'EOF'
import { Router } from 'express';
import { syncController } from '../controllers/syncController';

const router = Router();

// ENDPOINT SYNC TOTALMENTE LIBERADO - SEM AUTENTICAÇÃO
router.post('/', syncController.syncData);

export default router;
EOF

echo 'Reconstruindo photoRoutes...'
cat > src/routes/photoRoutes.ts << 'EOF'
import { Router } from 'express';
import { photoController } from '../controllers/photoController';

const router = Router();

// TODAS AS ROTAS LIBERADAS - SEM AUTENTICAÇÃO
router.post('/inspections/:inspectionId/photos', photoController.addPhoto);
router.get('/inspections/:inspectionId/photos', photoController.getPhotosByInspectionId);
router.delete('/photos/:id', photoController.deletePhoto);

export default router;
EOF

echo 'Rotas reconstruídas!'
"

echo ""
echo "📋 5. Rebuild da API..."
docker compose down
docker compose up -d --build

echo ""
echo "⏳ Aguardando 45 segundos..."
sleep 45

echo ""
echo "📋 6. Testando rotas corrigidas..."
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
docker logs ronda_check_api --tail 10

echo ""
echo "🎯 RESULTADO ESPERADO:"
echo "✅ Status 200 para todas as requisições"
echo "✅ Rotas funcionando"
echo "✅ Sem erro 404"
echo "✅ CORS funcionando"

echo ""
echo "�� ROTAS CORRIGIDAS!" 