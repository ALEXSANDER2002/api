#!/bin/bash

echo "🔍 Diagnosticando problemas HTTPS/SSL"
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

error() {
    echo -e "${RED}[ERRO] $1${NC}"
}

warning() {
    echo -e "${YELLOW}[AVISO] $1${NC}"
}

# 1. Testar HTTP vs HTTPS
log "1. Testando HTTP vs HTTPS..."
echo "curl -I http://rondacheck.com.br/health"
curl -I http://rondacheck.com.br/health
echo ""

echo "curl -I https://rondacheck.com.br/health"
curl -I https://rondacheck.com.br/health
echo ""

# 2. Testar com verbose para ver detalhes
log "2. Testando com verbose..."
echo "curl -v https://rondacheck.com.br/health"
curl -v https://rondacheck.com.br/health 2>&1 | head -20
echo ""

# 3. Verificar certificado SSL
log "3. Verificando certificado SSL..."
echo "openssl s_client -connect rondacheck.com.br:443 -servername rondacheck.com.br < /dev/null 2>/dev/null | openssl x509 -noout -dates"
openssl s_client -connect rondacheck.com.br:443 -servername rondacheck.com.br < /dev/null 2>/dev/null | openssl x509 -noout -dates
echo ""

# 4. Verificar se há redirecionamento
log "4. Testando redirecionamento..."
echo "curl -L -I http://rondacheck.com.br/health"
curl -L -I http://rondacheck.com.br/health
echo ""

# 5. Testar localmente
log "5. Testando localmente..."
echo "curl -X GET http://localhost:3000/health"
curl -X GET http://localhost:3000/health
echo ""

# 6. Verificar configuração SSL do Nginx
log "6. Verificando configuração SSL do Nginx..."
echo "ls -la /etc/nginx/sites-available/"
ls -la /etc/nginx/sites-available/
echo ""

echo "cat /etc/nginx/sites-available/rondacheck.com.br"
cat /etc/nginx/sites-available/rondacheck.com.br
echo ""

# 7. Verificar se há configuração SSL
log "7. Verificando se há configuração SSL..."
if grep -q "listen 443" /etc/nginx/sites-available/rondacheck.com.br; then
    log "✅ Configuração SSL encontrada"
else
    warning "⚠️ Configuração SSL não encontrada"
fi

# 8. Verificar certificados
log "8. Verificando certificados..."
echo "ls -la /etc/letsencrypt/live/rondacheck.com.br/"
if [ -d "/etc/letsencrypt/live/rondacheck.com.br/" ]; then
    ls -la /etc/letsencrypt/live/rondacheck.com.br/
else
    error "❌ Diretório de certificados não encontrado"
fi
echo ""

# 9. Testar com diferentes User-Agents
log "9. Testando com diferentes User-Agents..."
echo "curl -H 'User-Agent: Mozilla/5.0' https://rondacheck.com.br/health"
curl -H 'User-Agent: Mozilla/5.0' https://rondacheck.com.br/health
echo ""

# 10. Verificar logs do Nginx
log "10. Verificando logs do Nginx..."
echo "tail -10 /var/log/nginx/rondacheck.error.log"
tail -10 /var/log/nginx/rondacheck.error.log
echo ""

echo "tail -5 /var/log/nginx/rondacheck.access.log"
tail -5 /var/log/nginx/rondacheck.access.log
echo ""

log "🔍 Diagnóstico HTTPS concluído!"
echo ""
echo "📋 Possíveis problemas:"
echo "1. Certificado SSL expirado"
echo "2. Configuração SSL ausente no Nginx"
echo "3. Redirecionamento HTTP → HTTPS não configurado"
echo "4. Firewall bloqueando HTTPS"
echo "5. Problema de DNS" 