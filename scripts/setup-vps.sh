#!/bin/bash

echo "🚀 Configurando VPS para RondaCheck API..."
echo ""

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Função para log
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
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

log "1. Atualizando sistema..."
apt update && apt upgrade -y

log "2. Instalando dependências..."
apt install -y nginx certbot python3-certbot-nginx curl

log "3. Configurando Nginx..."
cat > /etc/nginx/sites-available/rondacheck.com.br << 'EOF'
server {
    listen 80;
    server_name rondacheck.com.br www.rondacheck.com.br;

    # Logs
    access_log /var/log/nginx/rondacheck.access.log;
    error_log /var/log/nginx/rondacheck.error.log;

    # Configurações de proxy
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

log "4. Ativando site..."
ln -sf /etc/nginx/sites-available/rondacheck.com.br /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

log "5. Testando configuração do Nginx..."
if nginx -t; then
    log "Configuração do Nginx OK"
else
    error "Erro na configuração do Nginx"
    exit 1
fi

log "6. Configurando firewall..."
ufw allow 80
ufw allow 443
ufw allow 22
ufw --force enable

log "7. Reiniciando Nginx..."
systemctl restart nginx
systemctl enable nginx

log "8. Verificando status dos serviços..."
echo ""
echo "Status do Nginx:"
systemctl status nginx --no-pager -l

echo ""
echo "Status do Firewall:"
ufw status

echo ""
log "9. Testando conectividade..."
if curl -s http://localhost:3000/health > /dev/null; then
    log "✅ API está respondendo na porta 3000"
else
    warning "⚠️  API não está respondendo na porta 3000"
    warning "Certifique-se de que os containers Docker estão rodando"
fi

echo ""
log "10. Configuração básica concluída!"
echo ""
echo "📋 Próximos passos:"
echo "1. Configure o DNS do domínio rondacheck.com.br para apontar para este IP"
echo "2. Execute: sudo certbot --nginx -d rondacheck.com.br -d www.rondacheck.com.br"
echo "3. Teste a API: curl -X GET http://rondacheck.com.br/health"
echo "4. Monitore os logs: sudo tail -f /var/log/nginx/rondacheck.access.log"
echo ""
echo "🔧 Para verificar se tudo está funcionando:"
echo "curl -X POST http://rondacheck.com.br/sync \\"
echo "  -H \"Content-Type: application/json\" \\"
echo "  -H \"X-Client-Type: mobile\" \\"
echo "  -d '{\"users\": [], \"inspections\": [], \"photos\": []}'"
echo ""
log "Setup concluído! 🎉" 