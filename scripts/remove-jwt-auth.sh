#!/bin/bash

echo "🔓 REMOVENDO TODA AUTENTICAÇÃO JWT - LIBERANDO TUDO!"

echo ""
echo "📋 1. Verificando status atual..."
docker ps | grep ronda_check_api

echo ""
echo "📋 2. Aplicando mudanças para remover JWT..."
docker exec -it ronda_check_api sh -c "
cd /app

echo 'Removendo autenticação de inspectionRoutes...'
cat > /app/src/routes/inspectionRoutes.ts << 'EOF'
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

echo 'Removendo autenticação de userRoutes...'
cat > /app/src/routes/userRoutes.ts << 'EOF'
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

echo 'Removendo autenticação de photoRoutes...'
cat > /app/src/routes/photoRoutes.ts << 'EOF'
import { Router } from 'express';
import { photoController } from '../controllers/photoController';

const router = Router();

// TODAS AS ROTAS LIBERADAS - SEM AUTENTICAÇÃO
router.post('/inspections/:inspectionId/photos', photoController.addPhoto);
router.get('/inspections/:inspectionId/photos', photoController.getPhotosByInspectionId);
router.delete('/photos/:id', photoController.deletePhoto);

export default router;
EOF

echo 'Removendo autenticação de syncRoutes...'
cat > /app/src/routes/syncRoutes.ts << 'EOF'
import { Router } from 'express';
import { syncController } from '../controllers/syncController';

const router = Router();

// ENDPOINT SYNC TOTALMENTE LIBERADO - SEM AUTENTICAÇÃO
router.post('/', syncController.syncData);

export default router;
EOF

echo 'Mudanças aplicadas!'
"

echo ""
echo "📋 3. Rebuild da API..."
docker compose down
docker compose up -d --build

echo ""
echo "⏳ Aguardando 45 segundos..."
sleep 45

echo ""
echo "📋 4. Testando endpoints liberados..."
echo "Testando GET /inspections (sem token):"
curl -H "Origin: https://exemplo.com" \
  -v https://rondacheck.com.br/inspections 2>&1 | grep -E "(HTTP|Access-Control|{.*})"

echo ""
echo "Testando POST /sync (sem header mobile):"
curl -X POST https://rondacheck.com.br/sync \
  -H "Origin: https://exemplo.com" \
  -H "Content-Type: application/json" \
  -d '{"users":[],"inspections":[],"photos":[]}' \
  -v 2>&1 | grep -E "(HTTP|Access-Control|{.*})"

echo ""
echo "Testando GET /users (sem token):"
curl -H "Origin: https://exemplo.com" \
  -v https://rondacheck.com.br/users 2>&1 | grep -E "(HTTP|Access-Control|{.*})"

echo ""
echo "📋 5. Verificando logs..."
docker logs ronda_check_api --tail 10

echo ""
echo "🎯 RESULTADO ESPERADO:"
echo "✅ Todos os endpoints funcionando sem token"
echo "✅ Status 200 para todas as requisições"
echo "✅ CORS funcionando"
echo "✅ Sem erro 401 (não autorizado)"

echo ""
echo "🎉 TODA AUTENTICAÇÃO JWT REMOVIDA!"
echo "🔓 API TOTALMENTE LIBERADA!" 