#!/bin/bash

echo "🔧 Corrigindo permissões dos scripts..."

# Dar permissão de execução para todos os scripts
chmod +x scripts/*.sh

echo "✅ Permissões corrigidas!"
echo ""
echo "📋 Scripts disponíveis:"
ls -la scripts/*.sh

echo ""
echo "🚀 Agora você pode executar:"
echo "./scripts/get-token.sh"
echo "./scripts/create-admin-user.sh"
echo "./scripts/create-token.sh" 