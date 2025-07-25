#!/bin/bash

echo "🔍 Diagnosticando 502 Bad Gateway"
echo "================================="
echo ""

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"
}

warning() {
    echo -e "${YELLOW}[AVISO] $1${NC}"
}

error() {
    echo -e "${RED}[ERRO] $1${NC}"
}

# 1. Verificar se a API está rodando
log "1. Verificando se a API está rodando..."
echo "docker compose ps"
docker compose ps
echo ""

# 2. Verificar se a API responde localmente
log "2. Testando API localmente na porta 3000..."
echo "curl -X GET http://localhost:3000/health"
if curl -s http://localhost:3000/health > /dev/null; then
    log "✅ API respondendo na porta 3000"
    curl -s http://localhost:3000/health | head -1
else
    error "❌ API não respondendo na porta 3000"
fi
echo ""

# 3. Verificar se a API responde na porta 3001
log "3. Testando API na porta 3001 (caso ainda esteja rodando)..."
echo "curl -X GET http://localhost:3001/health"
if curl -s http://localhost:3001/health > /dev/null; then
    log "✅ API respondendo na porta 3001"
    curl -s http://localhost:3001/health | head -1
else
    log "ℹ️ API não respondendo na porta 3001"
fi
echo ""

# 4. Verificar configuração do Nginx
log "4. Verificando configuração do Nginx..."
echo "nginx -t"
nginx -t
echo ""

# 5. Verificar arquivo de configuração
log "5. Mostrando configuração do Nginx..."
echo "cat /etc/nginx/sites-available/rondacheck.com.br"
cat /etc/nginx/sites-available/rondacheck.com.br
echo ""

# 6. Verificar logs do Nginx
log "6. Verificando logs do Nginx..."
echo "tail -20 /var/log/nginx/error.log"
tail -20 /var/log/nginx/error.log
echo ""

# 7. Verificar se há conflitos de porta
log "7. Verificando portas em uso..."
echo "netstat -tlnp | grep :80"
netstat -tlnp | grep :80
echo ""
echo "netstat -tlnp | grep :3000"
netstat -tlnp | grep :3000
echo ""

# 8. Verificar se o Nginx está rodando
log "8. Verificando status do Nginx..."
echo "systemctl status nginx --no-pager -l"
systemctl status nginx --no-pager -l
echo ""

# 9. Testar conectividade direta
log "9. Testando conectividade direta..."
echo "telnet localhost 3000"
if command -v telnet >/dev/null 2>&1; then
    echo "quit" | telnet localhost 3000 2>/dev/null | head -5
else
    echo "nc -zv localhost 3000"
    nc -zv localhost 3000 2>&1
fi
echo ""

# 10. Verificar se há firewall bloqueando
log "10. Verificando firewall..."
echo "ufw status"
ufw status
echo ""

log "🔍 Diagnóstico concluído!"
echo ""
echo "📋 Próximos passos baseados no resultado:"
echo "1. Se API não responde na porta 3000: Reiniciar containers"
echo "2. Se Nginx tem erro: Corrigir configuração"
echo "3. Se há conflito de porta: Resolver conflito"
echo "4. Se firewall bloqueia: Liberar porta" 