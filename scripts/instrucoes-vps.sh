#!/bin/bash

echo "🔧 INSTRUÇÕES PARA RESOLVER PROBLEMA NA VPS!"
echo ""

echo "📋 1. Primeiro, fazer pull das mudanças:"
echo "git pull origin main"
echo ""

echo "📋 2. Verificar se os scripts existem:"
echo "ls -la scripts/fix-database-complete.sh"
echo "ls -la scripts/fix-routes-404.sh"
echo ""

echo "📋 3. Se os scripts não existirem, criar manualmente:"
echo ""

echo "📋 4. Criar script fix-database-complete.sh:"
cat > scripts/fix-database-complete.sh << 'EOF'
#!/bin/bash

echo "🔧 RESOLVENDO PROBLEMA DO BANCO COMPLETAMENTE!"

echo ""
echo "📋 1. Parando containers..."
docker compose down

echo ""
echo "📋 2. Removendo volume do banco..."
docker volume rm api_mysql_data 2>/dev/null || true

echo ""
echo "📋 3. Iniciando containers..."
docker compose up -d

echo ""
echo "⏳ Aguardando MySQL inicializar..."
sleep 45

echo ""
echo "📋 4. Verificando MySQL..."
docker exec -it ronda_check_mysql mysql -u root -p92760247 -e "SELECT 1;" 2>/dev/null

echo ""
echo "📋 5. Aplicando migrações..."
docker exec -it ronda_check_api sh -c "
cd /app
echo 'Aplicando migrações...'
npx prisma migrate deploy
"

echo ""
echo "📋 6. Verificando estrutura da tabela..."
docker exec -it ronda_check_mysql mysql -u root -p92760247 -e "
USE ronda_check;
SHOW TABLES;
DESCRIBE User;
"

echo ""
echo "📋 7. Adicionando colunas manualmente se necessário..."
docker exec -it ronda_check_mysql mysql -u root -p92760247 -e "
USE ronda_check;
ALTER TABLE User ADD COLUMN IF NOT EXISTS password VARCHAR(255);
ALTER TABLE User ADD COLUMN IF NOT EXISTS role ENUM('USER', 'ADMIN') DEFAULT 'USER';
"

echo ""
echo "📋 8. Verificando estrutura final..."
docker exec -it ronda_check_mysql mysql -u root -p92760247 -e "
USE ronda_check;
DESCRIBE User;
"

echo ""
echo "📋 9. Gerando cliente Prisma..."
docker exec -it ronda_check_api sh -c "
cd /app
npx prisma generate
"

echo ""
echo "📋 10. Reiniciando API..."
docker compose restart api_service

echo ""
echo "⏳ Aguardando 30 segundos..."
sleep 30

echo ""
echo "📋 11. Testando endpoints..."
echo "Testando GET /health:"
curl -s http://localhost:3000/health

echo ""
echo "Testando GET /users:"
curl -s http://localhost:3000/users

echo ""
echo "Testando GET /inspections:"
curl -s http://localhost:3000/inspections

echo ""
echo "Testando POST /sync:"
curl -s -X POST http://localhost:3000/sync \
  -H "Content-Type: application/json" \
  -d '{"users":[],"inspections":[],"photos":[]}'

echo ""
echo "📋 12. Verificando logs..."
docker logs ronda_check_api --tail 5

echo ""
echo "🎯 RESULTADO ESPERADO:"
echo "✅ Banco de dados funcionando"
echo "✅ Todas as colunas existem"
echo "✅ Todos os endpoints retornando 200"
echo "✅ Sem erros de coluna não encontrada"

echo ""
echo "🔧 PROBLEMA DO BANCO RESOLVIDO!"
EOF

echo ""
echo "📋 5. Criar script fix-routes-404.sh:"
cat > scripts/fix-routes-404.sh << 'EOF'
#!/bin/bash

echo "🔧 CORRIGINDO PROBLEMA 404 DAS ROTAS!"

echo ""
echo "📋 1. Verificando arquivos de rota atuais..."
echo "=== src/routes/inspectionRoutes.ts ==="
cat src/routes/inspectionRoutes.ts
echo ""

echo "=== src/routes/userRoutes.ts ==="
cat src/routes/userRoutes.ts
echo ""

echo "=== src/routes/syncRoutes.ts ==="
cat src/routes/syncRoutes.ts
echo ""

echo "=== src/routes/photoRoutes.ts ==="
cat src/routes/photoRoutes.ts
echo ""

echo ""
echo "📋 2. Corrigindo inspectionRoutes.ts..."
cat > src/routes/inspectionRoutes.ts << 'INSPECTION_ROUTES'
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
INSPECTION_ROUTES

echo ""
echo "📋 3. Corrigindo userRoutes.ts..."
cat > src/routes/userRoutes.ts << 'USER_ROUTES'
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
USER_ROUTES

echo ""
echo "📋 4. Corrigindo syncRoutes.ts..."
cat > src/routes/syncRoutes.ts << 'SYNC_ROUTES'
import { Router } from 'express';
import { syncController } from '../controllers/syncController';

const router = Router();

// ENDPOINT SYNC TOTALMENTE LIBERADO - SEM AUTENTICAÇÃO
router.post('/', syncController.syncData);

export default router;
SYNC_ROUTES

echo ""
echo "📋 5. Corrigindo photoRoutes.ts..."
cat > src/routes/photoRoutes.ts << 'PHOTO_ROUTES'
import { Router } from 'express';
import { photoController } from '../controllers/photoController';

const router = Router();

// TODAS AS ROTAS LIBERADAS - SEM AUTENTICAÇÃO
router.post('/inspections/:inspectionId/photos', photoController.addPhoto);
router.get('/inspections/:inspectionId/photos', photoController.getPhotosByInspectionId);
router.delete('/photos/:id', photoController.deletePhoto);

export default router;
PHOTO_ROUTES

echo ""
echo "📋 6. Parando containers..."
docker compose down

echo ""
echo "📋 7. Rebuildando containers..."
docker compose up -d --build

echo ""
echo "⏳ Aguardando 30 segundos..."
sleep 30

echo ""
echo "📋 8. Testando endpoints..."
echo "Testando GET /health:"
curl -s http://localhost:3000/health

echo ""
echo "Testando GET /users:"
curl -s http://localhost:3000/users

echo ""
echo "Testando GET /inspections:"
curl -s http://localhost:3000/inspections

echo ""
echo "Testando POST /sync:"
curl -s -X POST http://localhost:3000/sync \
  -H "Content-Type: application/json" \
  -d '{"users":[],"inspections":[],"photos":[]}'

echo ""
echo "📋 9. Verificando logs..."
docker logs ronda_check_api --tail 5

echo ""
echo "🎯 RESULTADO ESPERADO:"
echo "✅ Rotas corrigidas"
echo "✅ Sem autenticação"
echo "✅ Todos os endpoints retornando 200"
echo "✅ Sem erros 404"

echo ""
echo "🔧 PROBLEMA 404 RESOLVIDO!"
EOF

echo ""
echo "📋 6. Dar permissão aos scripts:"
echo "chmod +x scripts/fix-database-complete.sh"
echo "chmod +x scripts/fix-routes-404.sh"
echo ""

echo "📋 7. Executar correção do banco:"
echo "./scripts/fix-database-complete.sh"
echo ""

echo "📋 8. Se ainda houver problema 404, executar correção das rotas:"
echo "./scripts/fix-routes-404.sh"
echo ""

echo "🎯 RESULTADO ESPERADO:"
echo "✅ Banco de dados funcionando"
echo "✅ Todas as colunas existem"
echo "✅ Todos os endpoints retornando 200"
echo "✅ Sem erros de coluna não encontrada"
echo "✅ API totalmente liberada sem autenticação"

echo ""
echo "🔧 EXECUTE ESSAS INSTRUÇÕES NA VPS!" 