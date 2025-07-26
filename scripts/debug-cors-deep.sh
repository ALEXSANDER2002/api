#!/bin/bash

echo "🔍 Investigação profunda do CORS..."

echo ""
echo "📋 1. Verificando logs da API com domínio externo..."
echo "Fazendo request com https://exemplo.com..."
curl -X OPTIONS https://rondacheck.com.br/health \
  -H "Origin: https://exemplo.com" \
  -H "Access-Control-Request-Method: GET" \
  -v 2>&1 > /dev/null

echo ""
echo "Logs da API após request:"
docker logs ronda_check_api --tail 10

echo ""
echo "📋 2. Verificando se há função origin customizada..."
docker exec -it ronda_check_api sh -c "
cd /app
echo 'Verificando se há função origin no código:'
grep -n 'origin.*function\|origin.*=>' /app/src/app.ts
echo ''
echo 'Verificando se há origin no código compilado:'
grep -n 'origin' /app/dist/app.js | head -5
"

echo ""
echo "📋 3. Testando com função origin simples..."
docker exec -it ronda_check_api sh -c "
cd /app
echo 'Verificando configuração atual:'
grep -A 5 -B 5 'corsOptions' /app/src/app.ts
"

echo ""
echo "📋 4. Testando sem Origin header..."
echo "Testando OPTIONS sem Origin:"
curl -X OPTIONS https://rondacheck.com.br/health \
  -H "Access-Control-Request-Method: GET" \
  -v 2>&1 | grep -E "(Access-Control|HTTP|>|<)"

echo ""
echo "📋 5. Testando com Origin null..."
echo "Testando OPTIONS com Origin: null:"
curl -X OPTIONS https://rondacheck.com.br/health \
  -H "Origin: null" \
  -H "Access-Control-Request-Method: GET" \
  -v 2>&1 | grep -E "(Access-Control|HTTP|>|<)"

echo ""
echo "📋 6. Verificando se há middleware de erro interferindo..."
docker exec -it ronda_check_api sh -c "
cd /app
echo 'Verificando error handler:'
grep -A 10 'errorHandler' /app/src/app.ts
"

echo ""
echo "📋 7. Testando com configuração CORS mais simples..."
echo "Vou criar uma versão mais simples do CORS..."

docker exec -it ronda_check_api sh -c "
cd /app
echo 'Backup da configuração atual:'
cp /app/src/app.ts /app/src/app.ts.backup

echo 'Criando configuração CORS mais simples:'
cat > /app/src/app.ts.new << 'EOF'
import express, { Request, Response, NextFunction } from 'express';
import cors from 'cors';
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

// CORS SIMPLES - LIBERADO PARA TUDO
app.use(cors({
  origin: true,
  credentials: false
}));

app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

app.get('/', (req: Request, res: Response) => {
  res.send('API is running!');
});

app.use('/public', publicRoutes);
app.use('/auth', authRoutes);
app.use('/users', userRoutes);
app.use('/photos', photoRoutes);
app.use('/inspections', inspectionRoutes);
app.use('/sync', syncRoutes);

app.use(errorHandler);

export { prisma };
export default app;
EOF

echo 'Substituindo configuração:'
mv /app/src/app.ts.new /app/src/app.ts
"

echo ""
echo "📋 8. Rebuild com CORS simples..."
docker compose down
docker compose up -d --build

echo ""
echo "⏳ Aguardando 20 segundos..."
sleep 20

echo ""
echo "📋 9. Testando com CORS simples..."
echo "Testando com domínio externo:"
curl -X OPTIONS https://rondacheck.com.br/health \
  -H "Origin: https://exemplo.com" \
  -H "Access-Control-Request-Method: GET" \
  -v 2>&1 | grep -E "(Access-Control|HTTP|>|<)"

echo ""
echo "Testando GET com domínio externo:"
curl -H "Origin: https://exemplo.com" \
  -v https://rondacheck.com.br/health 2>&1 | grep -E "(Access-Control|HTTP|>|<)"

echo ""
echo "🎯 RESULTADO ESPERADO:"
echo "✅ Access-Control-Allow-Origin: https://exemplo.com"
echo "✅ Status 204 para OPTIONS"
echo "✅ Status 200 para GET"
echo "✅ Sem erro 500" 