#!/bin/bash

echo "🔧 Criando usuário administrador e gerando token JWT..."

# Entrar no container da API
docker exec -it ronda_check_api sh -c "
echo '📝 Criando usuário administrador...'

# Criar usuário admin via API
curl -X POST http://localhost:3000/auth/register \\
  -H 'Content-Type: application/json' \\
  -d '{
    \"name\": \"Admin RondaCheck\",
    \"email\": \"admin@rondacheck.com.br\",
    \"password\": \"admin123456\",
    \"role\": \"ADMIN\"
  }'

echo ''
echo '🔑 Fazendo login para gerar token...'

# Fazer login e obter token
TOKEN=\$(curl -s -X POST http://localhost:3000/auth/login \\
  -H 'Content-Type: application/json' \\
  -d '{
    \"email\": \"admin@rondacheck.com.br\",
    \"password\": \"admin123456\"
  }' | jq -r '.token')

echo ''
echo '✅ TOKEN JWT GERADO:'
echo '===================='
echo \$TOKEN
echo '===================='
echo ''
echo '📋 Como usar:'
echo 'curl -H \"Authorization: Bearer \$TOKEN\" https://rondacheck.com.br/inspections'
echo ''
echo '🔐 Credenciais do usuário:'
echo 'Email: admin@rondacheck.com.br'
echo 'Senha: admin123456'
echo 'Role: ADMIN'
" 