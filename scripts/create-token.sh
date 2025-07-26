#!/bin/bash

echo "🔧 Gerando token JWT para acesso..."

# Entrar no container da API e gerar token
docker exec -it ronda_check_api sh -c "
echo '🔑 Gerando token JWT...'

# Gerar token diretamente via Node.js
node -e \"
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');

// Dados do usuário admin
const userData = {
  id: 1,
  name: 'Admin RondaCheck',
  email: 'admin@rondacheck.com.br',
  role: 'ADMIN'
};

// Gerar token (expira em 30 dias)
const token = jwt.sign(userData, process.env.JWT_SECRET || 'sua_chave_secreta_aqui', { 
  expiresIn: '30d' 
});

console.log('✅ TOKEN JWT GERADO:');
console.log('====================');
console.log(token);
console.log('====================');
console.log('');
console.log('📋 Como usar:');
console.log('curl -H \"Authorization: Bearer ' + token + '\" https://rondacheck.com.br/inspections');
console.log('');
console.log('🔐 Dados do usuário:');
console.log('ID: ' + userData.id);
console.log('Email: ' + userData.email);
console.log('Role: ' + userData.role);
console.log('Expira em: 30 dias');
\"
" 