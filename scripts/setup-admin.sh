#!/bin/bash

echo "🔧 Configurando usuário admin e gerando token JWT..."

# Verificar se a API está rodando
echo "📡 Verificando se a API está online..."
API_RESPONSE=$(curl -s https://rondacheck.com.br/health)

if [[ $API_RESPONSE == *"OK"* ]]; then
    echo "✅ API está online"
else
    echo "❌ API não está respondendo"
    echo "Resposta: $API_RESPONSE"
    exit 1
fi

echo ""
echo "📝 Tentando criar usuário admin..."

# Tentar criar usuário admin
REGISTER_RESPONSE=$(curl -s -X POST https://rondacheck.com.br/auth/register \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "Admin RondaCheck",
    "email": "admin@rondacheck.com.br",
    "password": "admin123456",
    "role": "ADMIN"
  }')

echo "Resposta do registro: $REGISTER_RESPONSE"

echo ""
echo "🔑 Tentando fazer login..."

# Tentar fazer login
LOGIN_RESPONSE=$(curl -s -X POST https://rondacheck.com.br/auth/login \
  -H 'Content-Type: application/json' \
  -d '{
    "email": "admin@rondacheck.com.br",
    "password": "admin123456"
  }')

echo "Resposta do login: $LOGIN_RESPONSE"

# Extrair token da resposta
TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

if [ -n "$TOKEN" ]; then
    echo ""
    echo "✅ TOKEN JWT OBTIDO COM SUCESSO!"
    echo "================================="
    echo $TOKEN
    echo "================================="
    echo ""
    echo "📋 Como usar o token:"
    echo "curl -H \"Authorization: Bearer $TOKEN\" https://rondacheck.com.br/inspections"
    echo ""
    echo "🔐 Credenciais do usuário:"
    echo "Email: admin@rondacheck.com.br"
    echo "Senha: admin123456"
    echo "Role: ADMIN"
    echo ""
    echo "🎯 Teste o token:"
    echo "curl -H \"Authorization: Bearer $TOKEN\" https://rondacheck.com.br/inspections"
else
    echo ""
    echo "❌ Erro ao obter token"
    echo "Resposta completa do login: $LOGIN_RESPONSE"
    echo ""
    echo "🔍 Possíveis soluções:"
    echo "1. Verificar se o banco de dados está funcionando"
    echo "2. Verificar se as migrações foram aplicadas"
    echo "3. Verificar logs da API"
fi 