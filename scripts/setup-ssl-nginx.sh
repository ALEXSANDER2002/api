#!/bin/bash

echo "🔒 Configurando SSL no Nginx"
echo "============================"
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

# Verificar se os certificados existem
log "1. Verificando certificados SSL..."
if [ ! -d "/etc/letsencrypt/live/rondacheck.com.br/" ]; then
    error "❌ Certificados SSL não encontrados"
    echo "Execute primeiro: sudo certbot certonly --nginx -d rondacheck.com.br -d www.rondacheck.com.br"
    exit 1
fi

log "✅ Certificados encontrados"
ls -la /etc/letsencrypt/live/rondacheck.com.br/
echo ""

log "2. Parando Nginx..."
systemctl stop nginx

log "3. Criando configuração SSL..."
cat > /etc/nginx/sites-available/rondacheck.com.br << 'EOF'
# Redirecionamento HTTP para HTTPS
server {
    listen 80;
    server_name rondacheck.com.br www.rondacheck.com.br;
    return 301 https://$server_name$request_uri;
}

# Configuração HTTPS
server {
    listen 443 ssl http2;
    server_name rondacheck.com.br www.rondacheck.com.br;

    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/rondacheck.com.br/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/rondacheck.com.br/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

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

log "4. Ativando configuração..."
ln -sf /etc/nginx/sites-available/rondacheck.com.br /etc/nginx/sites-enabled/

log "5. Testando configuração..."
if nginx -t; then
    log "✅ Configuração do Nginx OK"
else
    error "❌ Erro na configuração do Nginx"
    exit 1
fi

log "6. Iniciando Nginx..."
systemctl start nginx
systemctl enable nginx

log "7. Verificando status..."
systemctl status nginx --no-pager -l

log "8. Testando conectividade..."
sleep 3

echo ""
log "Testando HTTP (deve redirecionar para HTTPS)..."
curl -I http://rondacheck.com.br/health

echo ""
log "Testando HTTPS..."
curl -I https://rondacheck.com.br/health

echo ""
log "🔒 SSL configurado com sucesso!"
echo ""
echo "📋 Teste final:"
echo "curl -X POST https://rondacheck.com.br/sync \\"
echo "  -H \"Content-Type: application/json\" \\"
echo "  -H \"X-Client-Type: mobile\" \\"
echo "  -d '{\"users\": [], \"inspections\": [], \"photos\": []}'"
echo ""
echo "🎯 Agora HTTPS deve funcionar perfeitamente!" 