# 🔍 Diagnóstico - Timeout na Sincronização Mobile

## 🚨 Problema Identificado

O app mobile está tentando sincronizar com:
- `https://rondacheck.com.br/sync` ❌ Timeout
- `https://www.rondacheck.com.br/sync` ❌ Timeout

## 🔧 Possíveis Causas

### 1. **API não está rodando na VPS**
- A API pode não estar iniciada
- Containers Docker podem estar parados
- Porta 3000 pode não estar exposta

### 2. **Configuração de DNS/Domínio**
- O domínio `rondacheck.com.br` pode não estar apontando para a VPS
- Pode estar faltando configuração de proxy reverso (Nginx/Apache)

### 3. **Firewall/Segurança**
- Porta 80/443 pode estar bloqueada
- Firewall da VPS pode estar bloqueando conexões

### 4. **Configuração de Proxy**
- Pode estar faltando proxy reverso para redirecionar `rondacheck.com.br` → `localhost:3000`

## 🛠️ Passos para Diagnóstico

### 1. **Verificar Status da API na VPS**
```bash
# Conectar na VPS
ssh usuario@ip-da-vps

# Verificar se os containers estão rodando
docker-compose ps

# Verificar logs da API
docker-compose logs -f api_service

# Testar se a API responde localmente
curl -X GET http://localhost:3000/health
```

### 2. **Verificar Configuração de Domínio**
```bash
# Verificar se o domínio resolve para o IP correto
nslookup rondacheck.com.br
dig rondacheck.com.br

# Verificar se a porta 80/443 está aberta
netstat -tlnp | grep :80
netstat -tlnp | grep :443
```

### 3. **Verificar Proxy Reverso (Nginx/Apache)**
```bash
# Se usar Nginx
sudo nginx -t
sudo systemctl status nginx
sudo cat /etc/nginx/sites-available/rondacheck.com.br

# Se usar Apache
sudo apache2ctl -t
sudo systemctl status apache2
sudo cat /etc/apache2/sites-available/rondacheck.com.br.conf
```

## 🔧 Soluções

### **Solução 1: Configurar Nginx (Recomendado)**

Crie o arquivo `/etc/nginx/sites-available/rondacheck.com.br`:

```nginx
server {
    listen 80;
    server_name rondacheck.com.br www.rondacheck.com.br;

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
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }
}
```

Ative o site:
```bash
sudo ln -s /etc/nginx/sites-available/rondacheck.com.br /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### **Solução 2: Configurar SSL/HTTPS (Opcional)**

```bash
# Instalar Certbot
sudo apt install certbot python3-certbot-nginx

# Obter certificado SSL
sudo certbot --nginx -d rondacheck.com.br -d www.rondacheck.com.br
```

### **Solução 3: Configurar Firewall**

```bash
# Permitir portas HTTP/HTTPS
sudo ufw allow 80
sudo ufw allow 443
sudo ufw allow 3000

# Verificar status
sudo ufw status
```

### **Solução 4: Verificar Docker Compose**

Certifique-se que o `docker-compose.yml` está expondo a porta corretamente:

```yaml
api_service:
  ports:
    - "3000:3000"  # Deve estar assim
```

## 🧪 Testes de Conectividade

### 1. **Teste Local na VPS**
```bash
# Teste básico
curl -X GET http://localhost:3000/health

# Teste com headers CORS
curl -X POST http://localhost:3000/sync \
  -H "Content-Type: application/json" \
  -H "X-Client-Type: mobile" \
  -d '{"users": [], "inspections": [], "photos": []}' \
  -v
```

### 2. **Teste Externo**
```bash
# De uma máquina externa
curl -X GET http://rondacheck.com.br/health
curl -X GET https://rondacheck.com.br/health

# Teste de conectividade
telnet rondacheck.com.br 80
telnet rondacheck.com.br 443
```

### 3. **Teste com Postman**
1. URL: `https://rondacheck.com.br/sync`
2. Method: `POST`
3. Headers:
   - `Content-Type: application/json`
   - `X-Client-Type: mobile`
4. Body: `{"users": [], "inspections": [], "photos": []}`

## 📱 Configuração Temporária no App Mobile

Se precisar testar rapidamente, configure o app para usar o IP da VPS diretamente:

```javascript
// Temporariamente, use o IP da VPS
const API_URL = 'http://IP-DA-VPS:3000';

// Ou use localhost se testando localmente
const API_URL = 'http://localhost:3000';
```

## 🚀 Comandos de Deploy na VPS

```bash
# 1. Conectar na VPS
ssh usuario@ip-da-vps

# 2. Ir para o diretório da API
cd /caminho/para/api

# 3. Fazer pull das alterações
git pull origin main

# 4. Parar containers
docker-compose down

# 5. Rebuild sem cache
docker-compose build --no-cache

# 6. Subir containers
docker-compose up -d

# 7. Verificar logs
docker-compose logs -f api_service

# 8. Testar API
curl -X GET http://localhost:3000/health
```

## 🔍 Logs Importantes

### Logs da API
```bash
docker-compose logs -f api_service
```

### Logs do Nginx
```bash
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

### Logs do Sistema
```bash
sudo journalctl -u nginx -f
sudo journalctl -u docker -f
```

## 📞 Próximos Passos

1. **Execute os testes de conectividade** na VPS
2. **Configure o proxy reverso** (Nginx/Apache)
3. **Verifique o DNS** do domínio
4. **Teste com Postman** antes do app mobile
5. **Configure SSL** se necessário
6. **Monitore os logs** para identificar problemas

---

**Última atualização**: 23/01/2025  
**Status**: 🔧 Em diagnóstico 