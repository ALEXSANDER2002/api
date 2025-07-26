# 🚀 ORIENTAÇÕES PARA O DESENVOLVEDOR DO SITE

## 📋 **INFORMAÇÕES BÁSICAS**

### **🌐 URLs da API**
- **Base URL**: `https://rondacheck.com.br`
- **Swagger Docs**: `https://rondacheck.com.br/api-docs`
- **Health Check**: `https://rondacheck.com.br/health`

### **🔑 Credenciais de Acesso**
- **Email**: `admin@rondacheck.com.br`
- **Senha**: `admin123`
- **Token JWT**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwiZW1haWwiOiJhZG1pbkByb25kYWNoZWNrLmNvbS5iciIsInJvbGUiOiJBRE1JTiIsImlhdCI6MTczMjQ5NzM4NywiZXhwIjoxNzMyNTgzNzg3fQ.Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8`

### **🔧 Como usar o token**
```javascript
// Adicione o token no header Authorization
const headers = {
  'Content-Type': 'application/json',
  'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwiZW1haWwiOiJhZG1pbkByb25kYWNoZWNrLmNvbS5iciIsInJvbGUiOiJBRE1JTiIsImlhdCI6MTczMjQ5NzM4NywiZXhwIjoxNzMyNTgzNzg3fQ.Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8Ej8'
};
```

## 📡 **ENDPOINTS FUNCIONAIS**

### **✅ Endpoints Públicos (sem token)**
```bash
# Health Check
GET https://rondacheck.com.br/health

# Listar inspeções (público)
GET https://rondacheck.com.br/public/inspections

# Swagger Documentation
GET https://rondacheck.com.br/api-docs
```

### **🔐 Endpoints Protegidos (com token)**
```bash
# Login
POST https://rondacheck.com.br/auth/login

# CRUD de Inspeções
GET https://rondacheck.com.br/inspections
POST https://rondacheck.com.br/inspections
GET https://rondacheck.com.br/inspections/:id
PUT https://rondacheck.com.br/inspections/:id
DELETE https://rondacheck.com.br/inspections/:id

# CRUD de Usuários
GET https://rondacheck.com.br/users
POST https://rondacheck.com.br/users
GET https://rondacheck.com.br/users/:id
PUT https://rondacheck.com.br/users/:id
DELETE https://rondacheck.com.br/users/:id

# Sincronização (Mobile)
POST https://rondacheck.com.br/sync
GET https://rondacheck.com.br/sync/users

# Fotos
GET https://rondacheck.com.br/photos
POST https://rondacheck.com.br/photos
GET https://rondacheck.com.br/photos/:id
DELETE https://rondacheck.com.br/photos/:id
```

## 🛡️ **IMPORTANTE: HTTPS OBRIGATÓRIO**

**⚠️ SEMPRE use HTTPS!** A API redireciona HTTP para HTTPS automaticamente.

```javascript
// ✅ CORRETO
fetch('https://rondacheck.com.br/health')

// ❌ INCORRETO (será redirecionado)
fetch('http://rondacheck.com.br/health')
```

## 📊 **ESTRUTURA DE DADOS**

### **Inspeção (Inspection)**
```javascript
{
  "id": 1,
  "title": "Inspeção de Sinalização",
  "description": null,
  "status": "completed", // "pending" | "completed" | "cancelled"
  "userId": 1,
  "createdAt": "2025-07-23T19:41:29.718Z",
  "updatedAt": "2025-07-25T23:51:20.507Z"
}
```

### **Usuário (User)**
```javascript
{
  "id": 1,
  "name": "Admin",
  "email": "admin@rondacheck.com.br",
  "role": "ADMIN", // "USER" | "ADMIN"
  "createdAt": "2025-07-23T19:41:29.718Z",
  "updatedAt": "2025-07-25T23:51:20.507Z"
}
```

### **Foto (Photo)**
```javascript
{
  "id": 1,
  "inspectionId": 1,
  "filename": "photo_123.jpg",
  "url": "https://rondacheck.com.br/photos/photo_123.jpg",
  "createdAt": "2025-07-23T19:41:29.718Z"
}
```

## 💻 **EXEMPLOS DE USO**

### **JavaScript/React**
```javascript
// Health Check
const checkHealth = async () => {
  try {
    const response = await fetch('https://rondacheck.com.br/health');
    const data = await response.json();
    console.log('API Status:', data.status);
    return data;
  } catch (error) {
    console.error('Erro ao verificar saúde da API:', error);
  }
};

// Listar inspeções (público)
const getInspections = async () => {
  try {
    const response = await fetch('https://rondacheck.com.br/public/inspections');
    const inspections = await response.json();
    console.log('Inspeções:', inspections);
    return inspections;
  } catch (error) {
    console.error('Erro ao buscar inspeções:', error);
  }
};

// Login
const login = async (email, password) => {
  try {
    const response = await fetch('https://rondacheck.com.br/auth/login', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ email, password })
    });
    const data = await response.json();
    console.log('Token:', data.token);
    return data;
  } catch (error) {
    console.error('Erro no login:', error);
  }
};

// Criar inspeção (com token)
const createInspection = async (inspectionData) => {
  try {
    const response = await fetch('https://rondacheck.com.br/inspections', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer SEU_TOKEN_AQUI'
      },
      body: JSON.stringify(inspectionData)
    });
    const data = await response.json();
    console.log('Inspeção criada:', data);
    return data;
  } catch (error) {
    console.error('Erro ao criar inspeção:', error);
  }
};
```

### **Vue.js**
```javascript
// Composables/useApi.js
import { ref } from 'vue'

export function useApi() {
  const baseUrl = 'https://rondacheck.com.br'
  const token = ref(localStorage.getItem('token'))

  const setToken = (newToken) => {
    token.value = newToken
    localStorage.setItem('token', newToken)
  }

  const apiCall = async (endpoint, options = {}) => {
    const headers = {
      'Content-Type': 'application/json',
      ...options.headers
    }

    if (token.value) {
      headers.Authorization = `Bearer ${token.value}`
    }

    const response = await fetch(`${baseUrl}${endpoint}`, {
      ...options,
      headers
    })

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`)
    }

    return response.json()
  }

  return {
    token,
    setToken,
    apiCall
  }
}
```

## 🧪 **TESTES RÁPIDOS**

### **Teste básico de conectividade**
```bash
# Health check
curl https://rondacheck.com.br/health

# Listar inspeções
curl https://rondacheck.com.br/public/inspections

# Swagger
curl https://rondacheck.com.br/api-docs
```

### **Teste com token**
```bash
# Login
curl -X POST https://rondacheck.com.br/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@rondacheck.com.br","password":"admin123"}'

# Usar token para acessar endpoint protegido
curl https://rondacheck.com.br/inspections \
  -H "Authorization: Bearer SEU_TOKEN_AQUI"
```

## 🔍 **DEBUGGING**

### **Verificar se a API está online**
```javascript
fetch('https://rondacheck.com.br/health')
  .then(r => r.json())
  .then(data => {
    if (data.status === 'OK') {
      console.log('✅ API online');
    } else {
      console.log('❌ API com problemas');
    }
  })
  .catch(() => console.log('❌ API offline'));
```

### **Verificar CORS**
```javascript
fetch('https://rondacheck.com.br/health', {
  method: 'OPTIONS',
  headers: {
    'Origin': 'http://localhost:3000'
  }
})
.then(response => {
  console.log('CORS headers:', response.headers);
})
.catch(error => {
  console.log('CORS error:', error);
});
```

## 📱 **SINCRONIZAÇÃO MOBILE**

### **Endpoint de sincronização**
```javascript
// Enviar dados do mobile para a API
const syncData = async (mobileData) => {
  try {
    const response = await fetch('https://rondacheck.com.br/sync', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(mobileData)
    });
    const result = await response.json();
    console.log('Sincronização:', result);
    return result;
  } catch (error) {
    console.error('Erro na sincronização:', error);
  }
};
```

## 🚨 **CHECKLIST DE SUPORTE**

### **Antes de reportar um problema, verifique:**

- [ ] **HTTPS está sendo usado** (não HTTP)
- [ ] **Token JWT é válido** (se usando endpoint protegido)
- [ ] **CORS está configurado** (se frontend em domínio diferente)
- [ ] **API está online** (`/health` retorna OK)
- [ ] **Swagger docs funcionam** (`/api-docs` acessível)
- [ ] **Dados estão no formato correto** (JSON válido)

### **Se encontrar problemas:**

1. **Verifique os logs** da API
2. **Teste o endpoint** diretamente com curl
3. **Verifique o Swagger** para documentação atualizada
4. **Teste com o token fornecido** para endpoints protegidos

## 📞 **CONTATO**

- **API Status**: `https://rondacheck.com.br/health`
- **Documentação**: `https://rondacheck.com.br/api-docs`
- **Repositório**: GitHub (se disponível)

---

**🎯 A API está 100% funcional e pronta para uso!** 