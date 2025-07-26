#!/bin/bash

echo "🧪 Testando todos os endpoints da API..."

echo ""
echo "📡 Testando conectividade básica..."

echo "1. Testando rota raiz (HTTP):"
curl -s http://rondacheck.com.br/

echo ""
echo "2. Testando rota raiz (HTTPS):"
curl -s https://rondacheck.com.br/

echo ""
echo "3. Testando health check (HTTP):"
curl -s http://rondacheck.com.br/health

echo ""
echo "4. Testando health check (HTTPS):"
curl -s https://rondacheck.com.br/health

echo ""
echo "5. Testando localhost:3000/health:"
curl -s http://localhost:3000/health

echo ""
echo "6. Testando rota pública de inspeções:"
curl -s https://rondacheck.com.br/public/inspections

echo ""
echo "7. Testando Swagger docs:"
curl -s -I https://rondacheck.com.br/api-docs

echo ""
echo "🔍 Verificando logs da API..."
docker logs ronda_check_api --tail 10

echo ""
echo "📋 Verificando rotas registradas no container..."
docker exec -it ronda_check_api sh -c "grep -r 'app.get\|app.post\|app.use' /app/src/ || echo 'Não foi possível verificar as rotas'"

echo ""
echo "🎯 Testando com token JWT:"
TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjUsImVtYWlsIjoiYWRtaW5Acm9uZGFjaGVjay5jb20uYnIiLCJyb2xlIjoiQURNSU4iLCJpYXQiOjE3NTM0OTA2NDYsImV4cCI6MTc1MzQ5NDI0Nn0.qB26xcrjjklKDkwzzqEdhM84CFBKzUUTVzFoaqKcvnY"

echo "8. Testando rota protegida de inspeções (HTTPS):"
curl -s -H "Authorization: Bearer $TOKEN" https://rondacheck.com.br/inspections

echo ""
echo "9. Testando rota protegida de inspeções (HTTP):"
curl -s -H "Authorization: Bearer $TOKEN" http://rondacheck.com.br/inspections 