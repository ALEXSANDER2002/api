#!/bin/bash

echo "🔧 Corrigindo problema da porta da API (v2)..."
echo ""

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERRO] $1${NC}"
}

warning() {
    echo -e "${YELLOW}[AVISO] $1${NC}"
}

log "1. Parando containers..."
docker compose down

log "2. Definindo porta correta..."
export PORT=3000
echo "PORT=$PORT"

log "3. Verificando configuração atual..."
echo "Porta atual da API:"
curl -s http://localhost:3001/health 2>/dev/null | head -1 || echo "Porta 3001 não responde"
curl -s http://localhost:3000/health 2>/dev/null | head -1 || echo "Porta 3000 não responde"

log "4. Rebuild dos containers com nova configuração..."
docker compose build --no-cache

log "5. Iniciando containers..."
docker compose up -d

log "6. Aguardando inicialização..."
sleep 15

log "7. Testando conectividade..."
echo ""
echo "Testando porta 3000:"
if curl -s http://localhost:3000/health > /dev/null; then
    log "✅ API respondendo na porta 3000"
    curl -s http://localhost:3000/health | head -1
else
    error "❌ API não respondendo na porta 3000"
fi

echo ""
echo "Testando porta 3001:"
if curl -s http://localhost:3001/health > /dev/null; then
    warning "⚠️  API ainda respondendo na porta 3001"
else
    log "✅ Porta 3001 não responde mais (correto)"
fi

log "8. Testando através do domínio..."
curl -I http://rondacheck.com.br/health

echo ""
log "🔧 Correção concluída!"
echo ""
echo "📋 Se ainda houver problemas:"
echo "1. Execute: sudo ./scripts/fix-nginx.sh"
echo "2. Teste: curl http://rondacheck.com.br/health"
echo "3. Configure SSL: sudo certbot --nginx -d rondacheck.com.br" 