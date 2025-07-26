#!/bin/bash

echo "🔧 Corrigindo endpoint /health - Versão 2..."

echo ""
echo "📋 Verificando se o endpoint /health está no app.js compilado..."
docker exec -it ronda_check_api sh -c "
echo 'Verificando se /health está no app.js...'
grep -n 'health' /app/dist/app.js
"

echo ""
echo "📋 Verificando se o endpoint /health está sendo registrado..."
docker exec -it ronda_check_api sh -c "
echo 'Verificando se app.get está no app.js...'
grep -n 'app.get' /app/dist/app.js
"

echo ""
echo "🔍 O problema pode ser que o endpoint /health não está sendo compilado corretamente."
echo "Vou verificar se há algum problema na ordem das rotas..."

echo ""
echo "📋 Verificando se há conflitos de rota..."
docker exec -it ronda_check_api sh -c "
echo 'Verificando todas as rotas registradas...'
grep -n 'app.use\|app.get\|app.post' /app/dist/app.js
"

echo ""
echo "🚀 Tentando solução: Mover endpoint /health para server.ts..."

# Criar um arquivo temporário para testar
cat > temp-server.js << 'EOF'
import app, { prisma } from './app.js';
import swaggerUi from 'swagger-ui-express';
import swaggerJsdoc from 'swagger-jsdoc';

const PORT = process.env.PORT || 3000;

// Health Check endpoint (ANTES do Swagger)
app.get('/health', async (req, res) => {
  try {
    await prisma.$queryRaw`SELECT 1`;
    res.json({
      status: 'OK',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      database: 'connected',
      version: '1.0.0'
    });
  } catch (error) {
    res.status(500).json({
      status: 'ERROR',
      timestamp: new Date().toISOString(),
      database: 'disconnected',
      error: 'Database connection failed'
    });
  }
});

// Swagger Configuration
const swaggerOptions = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'API de Inspeções',
      version: '1.0.0',
      description: 'Documentação da API Express + Prisma + MySQL para o sistema Ronda Check',
    },
    servers: [
      { url: "https://rondacheck.com.br" }
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
        },
      },
    },
  },
  apis: [
    './src/routes/*.ts',
    './src/controllers/*.ts',
    './dist/routes/*.js',
    './dist/controllers/*.js'
  ],
};

const swaggerSpec = swaggerJsdoc(swaggerOptions);

// Swagger UI
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

// Rota para servir o JSON cru do OpenAPI
app.get('/swagger.json', (req, res) => {
  res.setHeader('Content-Type', 'application/json');
  res.send(swaggerSpec);
});

// Server Start
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Swagger docs available at http://localhost:${PORT}/api-docs`);
  console.log(`Swagger JSON available at http://localhost:${PORT}/swagger.json`);
});
EOF

echo ""
echo "📋 Criado arquivo temporário temp-server.js"
echo "Este arquivo move o endpoint /health para server.ts"

echo ""
echo "🎯 Para aplicar a correção:"
echo "1. Copie o conteúdo de temp-server.js para src/server.ts"
echo "2. Remova o endpoint /health de src/app.ts"
echo "3. Rebuild da API"

echo ""
echo "🚀 Alternativa: Rebuild completo da API..."
docker compose down
docker compose up -d --build

echo ""
echo "⏳ Aguardando 15 segundos..."
sleep 15

echo ""
echo "🧪 Testando novamente..."
curl -s http://localhost:3000/health

echo ""
echo "🧪 Testando via HTTPS..."
curl -s https://rondacheck.com.br/health 