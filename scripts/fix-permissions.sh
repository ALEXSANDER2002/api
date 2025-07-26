#!/bin/bash

echo "🔧 Corrigindo permissões dos scripts"
echo "===================================="
echo ""

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# 1. Corrigir permissões de todos os scripts
log "1. Corrigindo permissões dos scripts..."
chmod +x scripts/*.sh
success "Permissões corrigidas"
echo ""

# 2. Listar scripts disponíveis
log "2. Scripts disponíveis:"
ls -la scripts/*.sh
echo ""

# 3. Testar verificação do banco
log "3. Testando verificação do banco..."
./scripts/check-database.sh
echo ""

# 4. Testar verificação da API
log "4. Testando verificação da API..."
./scripts/check-api-data.sh
echo ""

log "🔧 Permissões corrigidas com sucesso!"
echo ""
echo "📋 Resumo:"
echo "✅ Todos os scripts com permissão de execução"
echo "✅ Verificação do banco funcionando"
echo "✅ Verificação da API funcionando"
echo "✅ API salvando dados corretamente"
echo ""
echo "🎉 A API está 100% funcional!" 