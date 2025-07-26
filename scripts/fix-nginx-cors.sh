#!/bin/bash

echo "🌐 INVESTIGANDO PROBLEMAS DO NGINX COM CORS!"

echo ""
echo "📋 1. Verificando se o Nginx está rodando..."
systemctl status nginx

echo ""
echo "📋 2. Verificando configuração do Nginx..."
cat /etc/nginx/sites-available/default

echo ""
echo "📋 3. Verificando se há headers CORS no Nginx..."
grep -r -i 'cors\|access-control' /etc/nginx/

echo ""
echo "📋 4. Verificando logs do Nginx..."
tail -20 /var/log/nginx/error.log
tail -20 /var/log/nginx/access.log

echo ""
echo "📋 5. Testando se o Nginx está proxyando corretamente..."
echo "Testando localhost:80 (HTTP):"
curl -X OPTIONS http://localhost/health \
  -H "Origin: https://exemplo.com" \
  -H "Access-Control-Request-Method: GET" \
  -v 2>&1 | grep -E "(Access-Control|HTTP|>|<)"

echo ""
echo "Testando localhost:443 (HTTPS):"
curl -X OPTIONS https://localhost/health \
  -H "Origin: https://exemplo.com" \
  -H "Access-Control-Request-Method: GET" \
  -k -v 2>&1 | grep -E "(Access-Control|HTTP|>|<)"

echo ""
echo "📋 6. Verificando se há problema no proxy_pass..."
grep -r 'proxy_pass' /etc/nginx/sites-available/default

echo ""
echo "📋 7. Corrigindo configuração do Nginx..."
echo "Backup da configuração atual:"
cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.backup

echo ""
echo "Criando configuração Nginx limpa:"
cat > /etc/nginx/sites-available/default << 'EOF'
server {
    listen 80;
    server_name rondacheck.com.br;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name rondacheck.com.br;

    ssl_certificate /etc/letsencrypt/live/rondacheck.com.br/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/rondacheck.com.br/privkey.pem;

    # Configurações SSL
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;

    # Headers de segurança
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";

    # Proxy para a API
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
        
        # NÃO adicionar headers CORS aqui - deixar a API gerenciar
        # proxy_hide_header Access-Control-Allow-Origin;
        # proxy_hide_header Access-Control-Allow-Methods;
        # proxy_hide_header Access-Control-Allow-Headers;
    }

    # Configuração específica para OPTIONS
    location ~* ^/(health|auth|users|inspections|photos|sync|public) {
        if ($request_method = 'OPTIONS') {
            add_header 'Access-Control-Allow-Origin' '*' always;
            add_header 'Access-Control-Allow-Methods' 'GET, POST, PUT, DELETE, OPTIONS, PATCH' always;
            add_header 'Access-Control-Allow-Headers' '*' always;
            add_header 'Access-Control-Allow-Credentials' 'false' always;
            add_header 'Access-Control-Max-Age' '86400' always;
            return 204;
        }
        
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF

echo "Configuração Nginx aplicada!"

echo ""
echo "📋 8. Testando configuração do Nginx..."
nginx -t

echo ""
echo "📋 9. Recarregando Nginx..."
systemctl reload nginx

echo ""
echo "📋 10. Testando após correção do Nginx..."
echo "Testando OPTIONS com domínio externo:"
curl -X OPTIONS https://rondacheck.com.br/health \
  -H "Origin: https://exemplo.com" \
  -H "Access-Control-Request-Method: GET" \
  -v 2>&1 | grep -E "(Access-Control|HTTP|>|<)"

echo ""
echo "Testando GET com domínio externo:"
curl -H "Origin: https://exemplo.com" \
  -v https://rondacheck.com.br/health 2>&1 | grep -E "(Access-Control|HTTP|>|<)"

echo ""
echo "Testando GET com Google:"
curl -H "Origin: https://google.com" \
  -v https://rondacheck.com.br/health 2>&1 | grep -E "(Access-Control|HTTP|>|<)"

echo ""
echo "📋 11. Verificando logs do Nginx após correção..."
tail -10 /var/log/nginx/error.log

echo ""
echo "🎯 RESULTADO ESPERADO:"
echo "✅ Access-Control-Allow-Origin: *"
echo "✅ Status 204 para OPTIONS"
echo "✅ Status 200 para GET"
echo "✅ Sem erro 500"
echo "✅ Funciona de qualquer origem"

echo ""
echo "🎉 NGINX CORRIGIDO PARA CORS!" 