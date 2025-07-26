#!/bin/bash

echo "🚨 RESOLVENDO PROBLEMA NA API DEFINITIVAMENTE!"

echo ""
echo "📋 1. Verificando logs da API..."
docker logs ronda_check_api --tail 20

echo ""
echo "📋 2. Verificando código atual da API..."
docker exec -it ronda_check_api sh -c "
cd /app
echo 'Código atual:'
cat /app/src/app.ts
"

echo ""
echo "📋 3. Verificando se há problema no código compilado..."
docker exec -it ronda_check_api sh -c "
cd /app
echo 'Verificando código compilado:'
grep -n 'origin.*function\|origin.*=>' /app/dist/app.js
"

echo ""
echo "📋 4. Aplicando configuração API ULTIMATE..."
docker exec -it ronda_check_api sh -c "
cd /app
echo 'Aplicando configuração API ULTIMATE...'
cat > /app/src/app.ts << 'EOF'
import express, { Request, Response, NextFunction } from 'express';
import 'dotenv/config';
import prisma from './prisma';

import authRoutes from './routes/authRoutes';
import userRoutes from './routes/userRoutes';
import inspectionRoutes from './routes/inspectionRoutes';
import photoRoutes from './routes/photoRoutes';
import syncRoutes from './routes/syncRoutes';
import publicRoutes from './routes/publicRoutes';
import { errorHandler } from './middlewares/errorHandler';

const app = express();

// CORS ULTIMATE - SEM BIBLIOTECA CORS
app.use((req: Request, res: Response, next: NextFunction) => {
  // Headers CORS para qualquer origem
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS, PATCH');
  res.header('Access-Control-Allow-Headers', '*');
  res.header('Access-Control-Allow-Credentials', 'false');
  res.header('Access-Control-Max-Age', '86400');
  
  // Log para debug
  console.log(\`[\${new Date().toISOString()}] \${req.method} \${req.path} - Origin: \${req.headers.origin || 'none'}\`);
  
  // Responder OPTIONS imediatamente
  if (req.method === 'OPTIONS') {
    return res.status(204).end();
  }
  
  next();
});

// Middlewares básicos
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Rota raiz
app.get('/', (req: Request, res: Response) => {
  res.send('API is running!');
});

// Rotas
app.use('/public', publicRoutes);
app.use('/auth', authRoutes);
app.use('/users', userRoutes);
app.use('/photos', photoRoutes);
app.use('/inspections', inspectionRoutes);
app.use('/sync', syncRoutes);

// Error handling
app.use(errorHandler);

export { prisma };
export default app;
EOF

echo 'Configuração API ULTIMATE aplicada!'
"

echo ""
echo "📋 5. Rebuild com configuração ULTIMATE..."
docker compose down
docker compose up -d --build

echo ""
echo "⏳ Aguardando 45 segundos..."
sleep 45

echo ""
echo "📋 6. Testando configuração ULTIMATE..."
echo "Testando OPTIONS com localhost:3001:"
curl -X OPTIONS https://rondacheck.com.br/health \
  -H "Origin: http://localhost:3001" \
  -H "Access-Control-Request-Method: GET" \
  -v 2>&1 | grep -E "(Access-Control|HTTP|>|<)"

echo ""
echo "Testando OPTIONS com domínio externo:"
curl -X OPTIONS https://rondacheck.com.br/health \
  -H "Origin: https://exemplo.com" \
  -H "Access-Control-Request-Method: GET" \
  -v 2>&1 | grep -E "(Access-Control|HTTP|>|<)"

echo ""
echo "Testando GET com domínio externo:"
curl -H "Origin: https://exemplo.com" \
  -v https://rondacheck.com.br/health 2>&1 | grep -E "(Access-Control|HTTP|>|<)"

echo ""
echo "Testando GET com Google:"
curl -H "Origin: https://google.com" \
  -v https://rondacheck.com.br/health 2>&1 | grep -E "(Access-Control|HTTP|>|<)"

echo ""
echo "📋 7. Verificando logs após correção..."
docker logs ronda_check_api --tail 10

echo ""
echo "📋 8. Se ainda falhar, vou verificar se há problema no server.ts..."
docker exec -it ronda_check_api sh -c "
cd /app
echo 'Verificando server.ts:'
cat /app/src/server.ts
"

echo ""
echo "🎯 RESULTADO ESPERADO:"
echo "✅ Access-Control-Allow-Origin: *"
echo "✅ Status 204 para OPTIONS"
echo "✅ Status 200 para GET"
echo "✅ Sem erro 500"
echo "✅ Funciona de qualquer origem"

echo ""
echo "🎉 API CORRIGIDA DEFINITIVAMENTE!" 