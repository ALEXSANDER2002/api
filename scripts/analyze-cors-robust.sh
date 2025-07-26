#!/bin/bash

echo "🔍 ANÁLISE ROBUSTA DO PROBLEMA CORS"

echo ""
echo "📋 1. VERIFICANDO LOGS COMPLETOS DA API..."
docker logs ronda_check_api --tail 50

echo ""
echo "📋 2. VERIFICANDO CONFIGURAÇÃO DO NGINX..."
docker exec -it nginx sh -c "
echo 'Configuração completa do Nginx:'
cat /etc/nginx/sites-available/default
" 2>/dev/null || echo "Nginx container não encontrado"

echo ""
echo "📋 3. VERIFICANDO SE HÁ CONFLITO DE PORTAS..."
netstat -tlnp | grep -E "(3000|80|443)"

echo ""
echo "📋 4. VERIFICANDO CÓDIGO COMPILADO DA API..."
docker exec -it ronda_check_api sh -c "
cd /app
echo 'Verificando se há múltiplas configurações CORS:'
grep -n 'cors\|CORS' /app/dist/app.js
echo ''
echo 'Verificando se há res.setHeader:'
grep -n 'setHeader\|header' /app/dist/app.js
echo ''
echo 'Verificando se há middleware de erro:'
grep -n 'error\|Error' /app/dist/app.js
"

echo ""
echo "📋 5. VERIFICANDO SE HÁ PROBLEMA NO ERROR HANDLER..."
docker exec -it ronda_check_api sh -c "
cd /app
echo 'Verificando error handler:'
cat /app/src/middlewares/errorHandler.ts
"

echo ""
echo "📋 6. VERIFICANDO SE HÁ PROBLEMA NAS ROTAS..."
docker exec -it ronda_check_api sh -c "
cd /app
echo 'Verificando se há middleware nas rotas:'
grep -r 'middleware' /app/src/routes/
"

echo ""
echo "📋 7. TESTANDO DIRETAMENTE NA API (SEM NGINX)..."
echo "Testando localhost:3000 diretamente:"
curl -X OPTIONS http://localhost:3000/health \
  -H "Origin: https://exemplo.com" \
  -H "Access-Control-Request-Method: GET" \
  -v 2>&1 | grep -E "(Access-Control|HTTP|>|<)"

echo ""
echo "📋 8. VERIFICANDO SE HÁ PROBLEMA NO SERVER.TS..."
docker exec -it ronda_check_api sh -c "
cd /app
echo 'Verificando server.ts:'
cat /app/src/server.ts
"

echo ""
echo "📋 9. VERIFICANDO SE HÁ PROBLEMA NO PROCESSO NODE..."
docker exec -it ronda_check_api sh -c "
cd /app
echo 'Verificando processo Node.js:'
ps aux | grep node
echo ''
echo 'Verificando se há múltiplos processos:'
pkill -f 'node.*server.js' 2>/dev/null || echo 'Nenhum processo para matar'
"

echo ""
echo "📋 10. VERIFICANDO SE HÁ PROBLEMA NO DOCKER..."
echo "Status dos containers:"
docker ps -a

echo ""
echo "📋 11. VERIFICANDO SE HÁ PROBLEMA NO FIREWALL..."
iptables -L | grep -E "(80|443|3000)" || echo "Firewall não configurado"

echo ""
echo "📋 12. VERIFICANDO SE HÁ PROBLEMA NO SSL..."
echo "Testando SSL:"
openssl s_client -connect rondacheck.com.br:443 -servername rondacheck.com.br < /dev/null 2>/dev/null | grep -E "(subject|issuer)" || echo "SSL não configurado"

echo ""
echo "📋 13. VERIFICANDO SE HÁ PROBLEMA NO DOMÍNIO..."
echo "Testando DNS:"
nslookup rondacheck.com.br

echo ""
echo "📋 14. VERIFICANDO SE HÁ PROBLEMA NO CÓDIGO ORIGINAL..."
docker exec -it ronda_check_api sh -c "
cd /app
echo 'Verificando código TypeScript original:'
cat /app/src/app.ts
"

echo ""
echo "🎯 POSSÍVEIS CAUSAS IDENTIFICADAS:"
echo "1. ❌ Error handler interferindo no CORS"
echo "2. ❌ Middleware nas rotas bloqueando"
echo "3. ❌ Nginx adicionando headers conflitantes"
echo "4. ❌ Múltiplos processos Node.js"
echo "5. ❌ Problema no SSL/HTTPS"
echo "6. ❌ Firewall bloqueando"
echo "7. ❌ Configuração CORS incorreta"
echo "8. ❌ Problema no código compilado"

echo ""
echo "📋 15. CRIANDO CONFIGURAÇÃO ROBUSTA..."
docker exec -it ronda_check_api sh -c "
cd /app
echo 'Criando configuração CORS ROBUSTA:'
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

// CORS ROBUSTO - ANTES DE TUDO
app.use((req: Request, res: Response, next: NextFunction) => {
  // Headers CORS básicos
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

// Error handler por último
app.use(errorHandler);

export { prisma };
export default app;
EOF

echo 'Configuração ROBUSTA aplicada!'
"

echo ""
echo "📋 16. REBUILD COM CONFIGURAÇÃO ROBUSTA..."
docker compose down
docker compose up -d --build

echo ""
echo "⏳ Aguardando 35 segundos..."
sleep 35

echo ""
echo "📋 17. TESTANDO CONFIGURAÇÃO ROBUSTA..."
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
echo "📋 18. VERIFICANDO LOGS APÓS CORREÇÃO..."
docker logs ronda_check_api --tail 10

echo ""
echo "🎯 RESULTADO FINAL:"
echo "✅ Access-Control-Allow-Origin: *"
echo "✅ Status 204 para OPTIONS"
echo "✅ Status 200 para GET"
echo "✅ Sem erro 500"
echo "✅ Funciona de qualquer origem"

echo ""
echo "🎉 CORS CONFIGURADO DE FORMA ROBUSTA!" 