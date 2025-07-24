# 🔄 Guia Completo - Endpoint de Sincronização RondaCheck

**Versão**: 1.0.0  
**Data**: 23 de Janeiro de 2025  
**Status**: ✅ Implementado e Funcional

## 📋 Visão Geral

O endpoint `/sync` da API RondaCheck implementa um sistema de **autenticação inteligente** que permite acesso diferenciado para aplicações mobile e web, garantindo segurança e facilidade de uso.

## 🎯 Funcionalidades

- ✅ **Sincronização de dados** entre app mobile e servidor
- ✅ **Autenticação inteligente** (público para mobile, autenticado para web)
- ✅ **Validação robusta** de dados de entrada
- ✅ **Tratamento de conflitos** durante sincronização
- ✅ **Logs detalhados** para debugging

## 🔐 Sistema de Autenticação Inteligente

### 📱 Acesso Mobile (Público)
- **Header obrigatório**: `X-Client-Type: mobile`
- **Token**: Não necessário
- **Uso**: Aplicações mobile que precisam sincronizar dados offline

### 🌐 Acesso Web (Autenticado)
- **Header obrigatório**: `Authorization: Bearer <token>`
- **Token**: Obrigatório (obtido via login)
- **Uso**: Interface web administrativa

## 📡 Endpoint de Sincronização

### URL
```
POST /sync
```

### Headers Obrigatórios

#### Para Mobile:
```http
Content-Type: application/json
X-Client-Type: mobile
```

#### Para Web:
```http
Content-Type: application/json
Authorization: Bearer <seu_token_jwt>
```

### Payload de Entrada
```json
{
  "users": [
    {
      "id": 1,
      "email": "user@example.com",
      "name": "Nome do Usuário",
      "password": "senha123",
      "createdAt": "2025-01-23T10:00:00Z"
    }
  ],
  "inspections": [
    {
      "id": 1,
      "title": "Inspeção Teste",
      "description": "Descrição da inspeção",
      "status": "pending",
      "userId": 1,
      "createdAt": "2025-01-23T10:00:00Z",
      "updatedAt": "2025-01-23T10:00:00Z"
    }
  ],
  "photos": [
    {
      "id": 1,
      "url": "https://example.com/photo.jpg",
      "inspectionId": 1,
      "createdAt": "2025-01-23T10:00:00Z"
    }
  ]
}
```

### Resposta de Sucesso
```json
{
  "syncedUsers": [
    {
      "id": 1,
      "email": "user@example.com",
      "name": "Nome do Usuário",
      "role": "USER",
      "createdAt": "2025-01-23T10:00:00Z"
    }
  ],
  "syncedInspections": [
    {
      "id": 1,
      "title": "Inspeção Teste",
      "description": "Descrição da inspeção",
      "status": "pending",
      "userId": 1,
      "createdAt": "2025-01-23T10:00:00Z",
      "updatedAt": "2025-01-23T10:00:00Z"
    }
  ],
  "syncedPhotos": [
    {
      "id": 1,
      "url": "https://example.com/photo.jpg",
      "inspectionId": 1,
      "createdAt": "2025-01-23T10:00:00Z"
    }
  ],
  "conflicts": []
}
```

## 🧪 Exemplos de Uso

### 1. Sincronização Mobile (cURL)
```bash
curl -X POST https://rondacheck.com.br/sync \
  -H "Content-Type: application/json" \
  -H "X-Client-Type: mobile" \
  -d '{
    "users": [],
    "inspections": [],
    "photos": []
  }'
```

### 2. Sincronização Web (cURL)
```bash
# Primeiro, fazer login para obter token
curl -X POST https://rondacheck.com.br/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@rondacheck.com.br",
    "password": "admin123"
  }'

# Depois, usar o token para sincronização
curl -X POST https://rondacheck.com.br/sync \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SEU_TOKEN_AQUI" \
  -d '{
    "users": [],
    "inspections": [],
    "photos": []
  }'
```

### 3. JavaScript (Mobile App)
```javascript
const syncData = async (data) => {
  try {
    const response = await fetch('https://rondacheck.com.br/sync', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Client-Type': 'mobile'
      },
      body: JSON.stringify(data)
    });
    
    const result = await response.json();
    console.log('Dados sincronizados:', result);
    return result;
  } catch (error) {
    console.error('Erro na sincronização:', error);
  }
};
```

### 4. JavaScript (Web App)
```javascript
const syncData = async (data, token) => {
  try {
    const response = await fetch('https://rondacheck.com.br/sync', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`
      },
      body: JSON.stringify(data)
    });
    
    const result = await response.json();
    console.log('Dados sincronizados:', result);
    return result;
  } catch (error) {
    console.error('Erro na sincronização:', error);
  }
};
```

## 🔍 Códigos de Resposta

### Sucesso
- **200 OK**: Sincronização realizada com sucesso

### Erros de Autenticação
- **401 Unauthorized**: Token inválido ou ausente (para web)
- **401 Unauthorized**: Header `X-Client-Type` ausente (para mobile)

### Erros de Validação
- **400 Bad Request**: Dados de entrada inválidos
- **400 Bad Request**: Schema de validação não atendido

### Erros de Servidor
- **500 Internal Server Error**: Erro interno do servidor

## 📊 Credenciais Padrão

### Usuário Administrador
- **Email**: `admin@rondacheck.com.br`
- **Senha**: `admin123`
- **Role**: `ADMIN`

### Usuário Teste
- **Email**: `teste@rondacheck.com.br`
- **Senha**: `123456`
- **Role**: `USER`

## 🔧 Endpoints Relacionados

### Autenticação
- `POST /auth/login` - Login de usuário
- `POST /auth/register` - Registro de usuário

### Monitoramento
- `GET /health` - Status da API e conexão com banco

### Gestão de Dados
- `GET /users` - Listar usuários (requer autenticação)
- `GET /inspections` - Listar inspeções (requer autenticação)
- `GET /photos` - Listar fotos (requer autenticação)

## 🚨 Tratamento de Conflitos

O sistema detecta e reporta conflitos durante a sincronização:

### Tipos de Conflito
- **Usuário duplicado**: Email já existe no banco
- **Inspeção não encontrada**: Referência inválida
- **Foto sem inspeção**: Inspeção não existe
- **Erro de validação**: Dados malformados

### Exemplo de Conflito
```json
{
  "syncedUsers": [],
  "syncedInspections": [],
  "syncedPhotos": [],
  "conflicts": [
    {
      "type": "user",
      "data": {
        "email": "user@example.com",
        "name": "Usuário Duplicado"
      },
      "error": "User with this email already exists"
    }
  ]
}
```

## 🔒 Segurança

### Para Mobile
- Acesso público controlado por header
- Validação de dados de entrada
- Logs de auditoria

### Para Web
- Autenticação JWT obrigatória
- Verificação de permissões
- Tokens com expiração

## 📝 Logs e Monitoramento

### Logs Automáticos
- Requisições mobile vs web
- Tempo de processamento
- Erros de validação
- Conflitos detectados

### Monitoramento
```bash
# Ver logs em tempo real
docker-compose logs -f api_service

# Verificar status da API
curl -X GET https://rondacheck.com.br/health
```

## 🚀 Deploy e Atualização

### Atualizar no Servidor
```bash
# Parar containers
docker-compose down

# Puxar alterações
git pull origin main

# Rebuild sem cache
docker-compose build --no-cache

# Subir containers
docker-compose up -d

# Verificar logs
docker-compose logs -f api_service
```

### Verificar Funcionamento
```bash
# Teste mobile
curl -X POST http://localhost:3001/sync \
  -H "Content-Type: application/json" \
  -H "X-Client-Type: mobile" \
  -d '{"users": [], "inspections": [], "photos": []}'

# Teste web (sem token - deve dar erro)
curl -X POST http://localhost:3001/sync \
  -H "Content-Type: application/json" \
  -d '{"users": [], "inspections": [], "photos": []}'
```

## 📞 Suporte

Para dúvidas ou problemas:
1. Verificar logs do servidor
2. Testar endpoints individualmente
3. Validar formato dos dados enviados
4. Confirmar headers corretos

---

**Última atualização**: 23/01/2025  
**Versão da API**: 1.0.0  
**Status**: ✅ Produção 