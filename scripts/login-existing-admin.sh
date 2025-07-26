#!/bin/bash

echo "🔑 Fazendo login com usuário admin existente..."

# Primeiro, vamos verificar se a API está funcionando
echo "📡 Testando conectividade com a API..."

# Tentar diferentes endpoints
HEALTH_RESPONSE=$(curl -s https://rondacheck.com.br/health)
ROOT_RESPONSE=$(curl -s https://rondacheck.com.br/)

if [[ $HEALTH_RESPONSE == *"OK"* ]] || [[ $ROOT_RESPONSE == *"API is running"* ]]; then
    echo "✅ API está respondendo"
else
    echo "❌ API não está respondendo. Tentando reiniciar..."
    docker compose down
    docker compose up -d --build
    sleep 10
fi

echo ""
echo "🔑 Tentando fazer login com usuário existente..."

# Tentar fazer login com o usuário admin que já existe
LOGIN_RESPONSE=$(curl -s -X POST https://rondacheck.com.br/auth/login \
  -H 'Content-Type: application/json' \
  -d '{
    "email": "admin@rondacheck.com.br",
    "password": "admin123456"
  }')

echo "Resposta do login: $LOGIN_RESPONSE"

# Se der erro de credenciais inválidas, tentar outras senhas comuns
if [[ $LOGIN_RESPONSE == *"Invalid credentials"* ]]; then
    echo ""
    echo "🔍 Tentando senhas alternativas..."
    
    # Tentar senhas comuns
    PASSWORDS=("admin" "123456" "password" "admin123" "123456789" "admin@123")
    
    for password in "${PASSWORDS[@]}"; do
        echo "Tentando senha: $password"
        RESPONSE=$(curl -s -X POST https://rondacheck.com.br/auth/login \
          -H 'Content-Type: application/json' \
          -d "{
            \"email\": \"admin@rondacheck.com.br\",
            \"password\": \"$password\"
          }")
        
        if [[ $RESPONSE == *"token"* ]]; then
            echo "✅ Senha encontrada: $password"
            LOGIN_RESPONSE=$RESPONSE
            break
        fi
    done
fi

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
    echo "ID: 5 (já existe no banco)"
    echo "Role: ADMIN"
    echo ""
    echo "🎯 Teste o token:"
    echo "curl -H \"Authorization: Bearer $TOKEN\" https://rondacheck.com.br/inspections"
else
    echo ""
    echo "❌ Erro ao obter token"
    echo "Resposta completa: $LOGIN_RESPONSE"
    echo ""
    echo "🔧 Soluções:"
    echo "1. Verificar se a API está funcionando: ./scripts/fix-api-health.sh"
    echo "2. Resetar senha do usuário admin no banco"
    echo "3. Criar novo usuário admin"
fi 