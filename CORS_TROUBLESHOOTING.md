# 🔧 Guia de Troubleshooting - CORS

## 🚨 Problemas Comuns de CORS

### 1. Erro: "Access to fetch at 'http://localhost:3000/sync' from origin 'http://localhost:3001' has been blocked by CORS policy"

**Causa**: A origem do seu app não está na lista de origens permitidas.

**Solução**: 
- Verifique se a URL do seu app está na lista `allowedOrigins` no arquivo `src/app.ts`
- Adicione a URL se necessário

### 2. Erro: "No 'Access-Control-Allow-Origin' header is present on the requested resource"

**Causa**: O servidor não está configurado corretamente para CORS.

**Solução**:
- Verifique se o middleware CORS está sendo carregado antes das rotas
- Reinicie o servidor após alterações na configuração

### 3. Erro: "Request header field X-Client-Type is not allowed by Access-Control-Allow-Headers"

**Causa**: O header `X-Client-Type` não está na lista de headers permitidos.

**Solução**: 
- O header já está configurado na lista `allowedHeaders`
- Verifique se não há duplicação na configuração

## 🧪 Como Testar

### 1. Usando o Script PowerShell (Windows)
```powershell
.\scripts\test-cors.ps1
```

### 2. Usando cURL (qualquer sistema)
```bash
# Teste básico
curl -X GET http://localhost:3000/health \
  -H "Origin: http://localhost:3000" \
  -v

# Teste mobile
curl -X POST http://localhost:3000/sync \
  -H "Content-Type: application/json" \
  -H "X-Client-Type: mobile" \
  -d '{"users": [], "inspections": [], "photos": []}' \
  -v
```

### 3. Usando Postman
1. Configure o header `Origin` com a URL do seu app
2. Para endpoints mobile, adicione o header `X-Client-Type: mobile`
3. Execute a requisição e verifique os headers de resposta

## 🔍 Debugging

### 1. Verificar Logs do Servidor
O servidor agora loga todas as requisições com informações de CORS:
```
[2025-01-23T10:00:00.000Z] POST /sync
Origin: http://localhost:3000
User-Agent: Mozilla/5.0...
X-Client-Type: mobile
```

### 2. Verificar Headers de Resposta
Procure por estes headers na resposta:
```
Access-Control-Allow-Origin: http://localhost:3000
Access-Control-Allow-Methods: GET,POST,PUT,DELETE,OPTIONS,PATCH
Access-Control-Allow-Headers: Origin,X-Requested-With,Content-Type,Accept,Authorization,X-Client-Type
```

### 3. Testar com Diferentes Origens
```javascript
// Teste no console do navegador
fetch('http://localhost:3000/health', {
  method: 'GET',
  headers: {
    'Content-Type': 'application/json'
  }
})
.then(response => response.json())
.then(data => console.log(data))
.catch(error => console.error('CORS Error:', error));
```

## 🛠️ Configuração Atual

### Origens Permitidas
- `http://localhost:3000` (Next.js padrão)
- `http://localhost:3001` (Vite/React padrão)
- `http://localhost:8080` (Vue.js padrão)
- `http://localhost:5173` (Vite padrão)
- `https://rondacheck.com.br` (produção)
- `exp://localhost:19000` (Expo/React Native)

### Headers Permitidos
- `Origin`
- `X-Requested-With`
- `Content-Type`
- `Accept`
- `Authorization`
- `X-Client-Type` (específico para mobile)
- `Cache-Control`
- `Pragma`

### Métodos Permitidos
- `GET`
- `POST`
- `PUT`
- `DELETE`
- `OPTIONS`
- `PATCH`

## 🔧 Soluções Específicas

### Para Apps Mobile (React Native, Expo)
```javascript
// Configuração no app mobile
const API_URL = 'http://localhost:3000';

const syncData = async (data) => {
  try {
    const response = await fetch(`${API_URL}/sync`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Client-Type': 'mobile'
      },
      body: JSON.stringify(data)
    });
    
    return await response.json();
  } catch (error) {
    console.error('Erro na sincronização:', error);
  }
};
```

### Para Apps Web (React, Vue, etc.)
```javascript
// Configuração no app web
const API_URL = 'http://localhost:3000';

const syncData = async (data, token) => {
  try {
    const response = await fetch(`${API_URL}/sync`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify(data)
    });
    
    return await response.json();
  } catch (error) {
    console.error('Erro na sincronização:', error);
  }
};
```

### Para Desenvolvimento Local
Se você estiver desenvolvendo localmente e ainda tiver problemas:

1. **Adicione sua origem específica**:
```typescript
const allowedOrigins = [
  // ... outras origens ...
  'http://localhost:5174', // Se usar porta diferente
  'http://127.0.0.1:3000', // IP local
  'http://192.168.1.100:3000' // IP da sua rede local
];
```

2. **Para desenvolvimento, permita todas as origens**:
```typescript
if (process.env.NODE_ENV === 'development') {
  return callback(null, true);
}
```

## 🚀 Próximos Passos

1. **Teste a configuração** usando os scripts fornecidos
2. **Verifique os logs** do servidor para identificar problemas
3. **Adicione sua origem específica** se necessário
4. **Teste com seu app** real
5. **Configure para produção** removendo origens de desenvolvimento

## 📞 Suporte

Se ainda tiver problemas:
1. Execute o script de teste
2. Verifique os logs do servidor
3. Confirme a URL exata do seu app
4. Teste com Postman primeiro
5. Verifique se não há proxy ou firewall bloqueando

---

**Última atualização**: 23/01/2025  
**Versão**: 1.0.0 