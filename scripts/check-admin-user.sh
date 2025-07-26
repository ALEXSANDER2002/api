#!/bin/bash

echo "🔍 Verificando usuário admin no banco de dados..."

# Verificar se o usuário admin existe
echo "📋 Verificando tabela User..."
docker exec -it ronda_check_mysql mysql -u root -p92760247 ronda_check -e "
SELECT id, name, email, role, createdAt, updatedAt 
FROM User 
WHERE email = 'admin@rondacheck.com.br';
"

echo ""
echo "📋 Listando todos os usuários:"
docker exec -it ronda_check_mysql mysql -u root -p92760247 ronda_check -e "
SELECT id, name, email, role, createdAt 
FROM User;
"

echo ""
echo "🔧 Se o usuário não existir, você pode criá-lo manualmente:"
echo "1. Acesse: https://rondacheck.com.br/api-docs"
echo "2. Procure por: POST /auth/register"
echo "3. Use o payload:"
echo '{
  "name": "Admin RondaCheck",
  "email": "admin@rondacheck.com.br",
  "password": "admin123456",
  "role": "ADMIN"
}'
echo ""
echo "4. Depois faça login em: POST /auth/login" 