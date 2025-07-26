#!/bin/bash

echo "🔍 Verificando configuração do Nginx..."

echo ""
echo "📋 Verificando se o Nginx está rodando..."
systemctl status nginx

echo ""
echo "📋 Verificando configuração do Nginx..."
sudo nginx -t

echo ""
echo "📋 Verificando sites habilitados..."
ls -la /etc/nginx/sites-enabled/

echo ""
echo "📋 Verificando configuração do rondacheck.com.br..."
cat /etc/nginx/sites-enabled/rondacheck

echo ""
echo "📋 Verificando logs do Nginx..."
sudo tail -n 10 /var/log/nginx/error.log

echo ""
echo "📋 Verificando logs de acesso..."
sudo tail -n 10 /var/log/nginx/access.log

echo ""
echo "🔍 Testando conectividade..."

echo "1. Testando localhost:3000 (diretamente na API):"
curl -s http://localhost:3000/health

echo ""
echo "2. Testando localhost:3000/ (rota raiz):"
curl -s http://localhost:3000/

echo ""
echo "3. Testando rondacheck.com.br (via Nginx):"
curl -s https://rondacheck.com.br/health

echo ""
echo "4. Testando rondacheck.com.br/ (rota raiz via Nginx):"
curl -s https://rondacheck.com.br/

echo ""
echo "🔍 Verificando se há conflitos de porta..."

# Verificar se a porta 3000 está sendo usada
echo "Verificando porta 3000:"
netstat -tlnp | grep :3000

echo ""
echo "Verificando porta 80:"
netstat -tlnp | grep :80

echo ""
echo "Verificando porta 443:"
netstat -tlnp | grep :443

echo ""
echo "🎯 Possíveis problemas identificados:"

echo "1. Se localhost:3000 funciona mas rondacheck.com.br não:"
echo "   - Problema na configuração do Nginx"
echo "   - Proxy não configurado corretamente"

echo ""
echo "2. Se nenhum dos dois funciona:"
echo "   - Problema na API"
echo "   - Rotas não registradas"

echo ""
echo "3. Se há erros no Nginx:"
echo "   - Configuração incorreta"
echo "   - Certificados SSL"

echo ""
echo "🚀 Soluções:"

echo "1. Se for problema do Nginx:"
echo "   sudo systemctl restart nginx"

echo ""
echo "2. Se for problema da API:"
echo "   docker compose restart api_service"

echo ""
echo "3. Se for problema de configuração:"
echo "   Verificar se o proxy está apontando para localhost:3000" 