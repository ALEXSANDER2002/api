#!/bin/bash

echo "🔍 Debug da VPS - RondaCheck API"
echo "=================================="

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

echo ""
log "1. Verificando status dos containers..."
docker-compose ps

echo ""
log "2. Verificando logs da API..."
docker-compose logs --tail=20 api_service

echo ""
log "3. Verificando se a porta 3000 está em uso..."
netstat -tlnp | grep :3000

echo ""
log "4. Verificando configuração do Nginx..."
nginx -t

echo ""
log "5. Verificando sites ativos do Nginx..."
ls -la /etc/nginx/sites-enabled/

echo ""
log "6. Verificando configuração do site..."
cat /etc/nginx/sites-available/rondacheck.com.br

echo ""
log "7. Testando conectividade interna..."
curl -v http://localhost:3000/health 2>&1 | head -20

echo ""
log "8. Testando conectividade externa..."
curl -v http://rondacheck.com.br/health 2>&1 | head -20

echo ""
log "9. Verificando logs do Nginx..."
tail -10 /var/log/nginx/rondacheck.access.log 2>/dev/null || echo "Log não encontrado"
tail -10 /var/log/nginx/rondacheck.error.log 2>/dev/null || echo "Log não encontrado"

echo ""
log "10. Verificando firewall..."
ufw status

echo ""
log "Debug concluído! 🎯" 