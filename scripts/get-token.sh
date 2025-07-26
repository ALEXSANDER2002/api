#!/bin/bash

echo "🔧 Obtendo token JWT via login na API..."

# Primeiro, vamos criar um usuário se não existir
echo "📝 Verificando/criando usuário admin..."

# Tentar criar usuário (pode falhar se já existir)
curl -s -X POST https://rondacheck.com.br/auth/register \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "Admin RondaCheck",
    "email": "admin@rondacheck.com.br",
    "password": "admin123456",
    "role": "ADMIN"
  }' > /dev/null

echo ""
echo "🔑 Fazendo login para obter token..."

# Fazer login e obter token
RESPONSE=$(curl -s -X POST https://rondacheck.com.br/auth/login \
  -H 'Content-Type: application/json' \
  -d '{
    "email": "admin@rondacheck.com.br",
    "password": "admin123456"
  }')

# Extrair token da resposta
TOKEN=$(echo $RESPONSE | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

if [ -n "$TOKEN" ]; then
    echo ""
    echo "✅ TOKEN JWT OBTIDO:"
    echo "===================="
    echo $TOKEN
    echo "===================="
    echo ""
    echo "📋 Como usar:"
    echo "curl -H \"Authorization: Bearer $TOKEN\" https://rondacheck.com.br/inspections"
    echo ""
    echo "🔐 Credenciais:"
    echo "Email: admin@rondacheck.com.br"
    echo "Senha: admin123456"
    echo "Role: ADMIN"
else
    echo "❌ Erro ao obter token. Resposta da API:"
    echo $RESPONSE
fi 