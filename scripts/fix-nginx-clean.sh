#!/bin/bash

echo "🧹 Limpando configurações conflitantes do Nginx"
echo "=============================================="
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

# Verificar se está rodando como root
if [ "$EUID" -ne 0 ]; then
    error "Este script deve ser executado como root (sudo)"
    exit 1
fi

log "1. Parando Nginx..."
systemctl stop nginx

log "2. Listando todas as configurações ativas..."
echo "ls -la /etc/nginx/sites-enabled/"
ls -la /etc/nginx/sites-enabled/
echo ""

log "3. Removendo TODAS as configurações..."
rm -f /etc/nginx/sites-enabled/*
echo "Configurações removidas:"
ls -la /etc/nginx/sites-enabled/
echo ""

log "4. Listando configurações disponíveis..."
echo "ls -la /etc/nginx/sites-available/"
ls -la /etc/nginx/sites-available/
echo ""

log "5. Removendo configurações conflitantes..."
rm -f /etc/nginx/sites-available/default
rm -f /etc/nginx/sites-available/rondacheck.com.br
echo "Configurações disponíveis após limpeza:"
ls -la /etc/nginx/sites-available/
echo ""

log "6. Criando configuração limpa para porta 3000..."
cat > /etc/nginx/sites-available/rondacheck.com.br << 'EOF'
server {
    listen 80;
    server_name rondacheck.com.br www.rondacheck.com.br;

    # Logs
    access_log /var/log/nginx/rondacheck.access.log;
    error_log /var/log/nginx/rondacheck.error.log;

    # Configurações de proxy para porta 3000
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        
        # Timeouts para sincronização
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
        proxy_send_timeout 300s;
        
        # Headers CORS
        add_header Access-Control-Allow-Origin * always;
        add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS, PATCH" always;
        add_header Access-Control-Allow-Headers "Origin, X-Requested-With, Content-Type, Accept, Authorization, X-Client-Type" always;
        
        # Preflight requests
        if ($request_method = 'OPTIONS') {
            add_header Access-Control-Allow-Origin * always;
            add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS, PATCH" always;
            add_header Access-Control-Allow-Headers "Origin, X-Requested-With, Content-Type, Accept, Authorization, X-Client-Type" always;
            add_header Access-Control-Max-Age 86400;
            add_header Content-Type 'text/plain; charset=utf-8';
            add_header Content-Length 0;
            return 204;
        }
    }

    # Health check endpoint
    location /health {
        proxy_pass http://localhost:3000/health;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

log "7. Ativando configuração..."
ln -sf /etc/nginx/sites-available/rondacheck.com.br /etc/nginx/sites-enabled/

log "8. Verificando configuração..."
echo "ls -la /etc/nginx/sites-enabled/"
ls -la /etc/nginx/sites-enabled/
echo ""

log "9. Testando configuração..."
if nginx -t; then
    log "✅ Configuração do Nginx OK"
else
    error "❌ Erro na configuração do Nginx"
    exit 1
fi

log "10. Iniciando Nginx..."
systemctl start nginx
systemctl enable nginx

log "11. Verificando status..."
systemctl status nginx --no-pager -l

log "12. Testando conectividade..."
sleep 3

echo ""
log "Testando API na porta 3000..."
if curl -s http://localhost:3000/health > /dev/null; then
    log "✅ API respondendo na porta 3000"
    curl -s http://localhost:3000/health | head -1
else
    error "❌ API não respondendo na porta 3000"
fi

echo ""
log "Testando através do domínio..."
curl -I http://rondacheck.com.br/health

echo ""
log "🧹 Limpeza concluída!"
echo ""
echo "📋 Teste final:"
echo "curl -X POST https://rondacheck.com.br/sync \\"
echo "  -H \"Content-Type: application/json\" \\"
echo "  -H \"X-Client-Type: mobile\" \\"
echo "  -d '{\"users\": [], \"inspections\": [], \"photos\": []}'"
echo ""
echo "🎯 Agora não deve haver mais conflitos!" 