# 📋 ORIENTAÇÕES PARA O DESENVOLVEDOR DO SITE

## 🎯 **RESUMO EXECUTIVO**

A API do RondaCheck está **100% funcional** e pronta para integração com o site. Todos os endpoints principais estão funcionando e testados.

---

## 🔗 **INFORMAÇÕES DA API**

### **URL Base:**
```
https://rondacheck.com.br
```

### **Documentação:**
```
https://rondacheck.com.br/api-docs/
```

---

## 🔐 **AUTENTICAÇÃO**

### **Token JWT Ativo:**
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjUsImVtYWlsIjoiYWRtaW5Acm9uZGFjaGVjay5jb20uYnIiLCJyb2xlIjoiQURNSU4iLCJpYXQiOjE3NTM0OTA2NDYsImV4cCI6MTc1MzQ5NDI0Nn0.qB26xcrjjklKDkwzzqEdhM84CFBKzUUTVzFoaqKcvnY
```

### **Credenciais do Usuário Admin:**
```
Email: admin@rondacheck.com.br
Senha: admin123
Role: ADMIN
```

### **Como usar o token:**
```javascript
// Exemplo em JavaScript/Fetch
const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjUsImVtYWlsIjoiYWRtaW5Acm9uZGFjaGVjay5jb20uYnIiLCJyb2xlIjoiQURNSU4iLCJpYXQiOjE3NTM0OTA2NDYsImV4cCI6MTc1MzQ5NDI0Nn0.qB26xcrjjklKDkwzzqEdhM84CFBKzUUTVzFoaqKcvnY';

fetch('https://rondacheck.com.br/inspections', {
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  }
})
.then(response => response.json())
.then(data => console.log(data));
```

---

## 📡 **ENDPOINTS DISPONÍVEIS**

### **✅ ENDPOINTS FUNCIONAIS**

#### **1. Health Check**
```http
GET https://rondacheck.com.br/health
```
**Resposta:**
```json
{
  "status": "OK",
  "timestamp": "2025-07-26T00:52:23.456Z",
  "uptime": 1234.56,
  "database": "connected",
  "version": "1.0.0"
}
```

#### **2. Listar Inspeções (Protegido)**
```http
GET https://rondacheck.com.br/inspections
Authorization: Bearer {TOKEN}
```
**Resposta:** Array com 30 inspeções
```json
[
  {
    "id": 1,
    "title": "Teste 3",
    "description": null,
    "status": "completed",
    "userId": 1,
    "createdAt": "2025-07-23T19:41:29.718Z",
    "updatedAt": "2025-07-25T23:51:20.507Z"
  }
  // ... mais inspeções
]
```

#### **3. Listar Inspeções (Público)**
```http
GET https://rondacheck.com.br/public/inspections
```
**Resposta:** Mesmo array de inspeções (sem autenticação)

#### **4. Buscar Inspeção por ID**
```http
GET https://rondacheck.com.br/inspections/{id}
Authorization: Bearer {TOKEN}
```

#### **5. Criar Inspeção**
```http
POST https://rondacheck.com.br/inspections
Authorization: Bearer {TOKEN}
Content-Type: application/json

{
  "title": "Nova Inspeção",
  "description": "Descrição da inspeção",
  "status": "pending",
  "userId": 1
}
```

#### **6. Atualizar Inspeção**
```http
PUT https://rondacheck.com.br/inspections/{id}
Authorization: Bearer {TOKEN}
Content-Type: application/json

{
  "title": "Inspeção Atualizada",
  "status": "completed"
}
```

#### **7. Deletar Inspeção**
```http
DELETE https://rondacheck.com.br/inspections/{id}
Authorization: Bearer {TOKEN}
```

#### **8. Listar Usuários**
```http
GET https://rondacheck.com.br/users
Authorization: Bearer {TOKEN}
```

#### **9. Criar Usuário**
```http
POST https://rondacheck.com.br/users
Content-Type: application/json

{
  "name": "Novo Usuário",
  "email": "usuario@exemplo.com",
  "password": "senha123",
  "role": "USER"
}
```

#### **10. Login**
```http
POST https://rondacheck.com.br/auth/login
Content-Type: application/json

{
  "email": "admin@rondacheck.com.br",
  "password": "admin123"
}
```
**Resposta:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 5,
    "name": "Administrador",
    "email": "admin@rondacheck.com.br",
    "role": "ADMIN"
  }
}
```

#### **11. Registro**
```http
POST https://rondacheck.com.br/auth/register
Content-Type: application/json

{
  "name": "Novo Usuário",
  "email": "usuario@exemplo.com",
  "password": "senha123",
  "role": "USER"
}
```

#### **12. Listar Fotos**
```http
GET https://rondacheck.com.br/photos
Authorization: Bearer {TOKEN}
```

#### **13. Upload de Foto**
```http
POST https://rondacheck.com.br/photos
Authorization: Bearer {TOKEN}
Content-Type: multipart/form-data

{
  "file": [arquivo],
  "inspectionId": 1,
  "description": "Descrição da foto"
}
```

---

## 🚨 **IMPORTANTE - HTTPS OBRIGATÓRIO**

### **✅ Use SEMPRE HTTPS:**
```javascript
// ✅ CORRETO
fetch('https://rondacheck.com.br/inspections')

// ❌ INCORRETO (vai dar erro 301)
fetch('http://rondacheck.com.br/inspections')
```

### **⚠️ Redirecionamento Automático:**
- HTTP → HTTPS: Redirecionamento automático 301
- Sempre use URLs com `https://`

---

## 📊 **DADOS DISPONÍVEIS**

### **Inspeções no Banco:**
- **Total:** 30 inspeções
- **Status:** pending, completed
- **Tipos:** Extintores, Sinalização, etc.

### **Usuários no Banco:**
- **Total:** 13 usuários
- **Admin:** admin@rondacheck.com.br (ID: 5)

### **Estrutura das Inspeções:**
```json
{
  "id": 1,
  "title": "Título da Inspeção",
  "description": "Descrição opcional",
  "status": "pending|completed",
  "userId": 1,
  "createdAt": "2025-07-23T19:41:29.718Z",
  "updatedAt": "2025-07-25T23:51:20.507Z"
}
```

---

## 🔧 **EXEMPLOS DE IMPLEMENTAÇÃO**

### **React/JavaScript:**
```javascript
// Configuração da API
const API_BASE = 'https://rondacheck.com.br';
const TOKEN = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjUsImVtYWlsIjoiYWRtaW5Acm9uZGFjaGVjay5jb20uYnIiLCJyb2xlIjoiQURNSU4iLCJpYXQiOjE3NTM0OTA2NDYsImV4cCI6MTc1MzQ5NDI0Nn0.qB26xcrjjklKDkwzzqEdhM84CFBKzUUTVzFoaqKcvnY';

// Função para buscar inspeções
async function getInspections() {
  try {
    const response = await fetch(`${API_BASE}/inspections`, {
      headers: {
        'Authorization': `Bearer ${TOKEN}`,
        'Content-Type': 'application/json'
      }
    });
    
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    const data = await response.json();
    return data;
  } catch (error) {
    console.error('Erro ao buscar inspeções:', error);
    throw error;
  }
}

// Função para criar inspeção
async function createInspection(inspectionData) {
  try {
    const response = await fetch(`${API_BASE}/inspections`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${TOKEN}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(inspectionData)
    });
    
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    const data = await response.json();
    return data;
  } catch (error) {
    console.error('Erro ao criar inspeção:', error);
    throw error;
  }
}

// Função para fazer login
async function login(email, password) {
  try {
    const response = await fetch(`${API_BASE}/auth/login`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ email, password })
    });
    
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }
    
    const data = await response.json();
    return data.token; // Retorna o token JWT
  } catch (error) {
    console.error('Erro no login:', error);
    throw error;
  }
}
```

### **Vue.js:**
```javascript
// Composables/api.js
import { ref } from 'vue'

const API_BASE = 'https://rondacheck.com.br'
const token = ref(localStorage.getItem('token') || '')

export function useApi() {
  const setToken = (newToken) => {
    token.value = newToken
    localStorage.setItem('token', newToken)
  }

  const apiRequest = async (endpoint, options = {}) => {
    const url = `${API_BASE}${endpoint}`
    const config = {
      headers: {
        'Content-Type': 'application/json',
        ...(token.value && { 'Authorization': `Bearer ${token.value}` }),
        ...options.headers
      },
      ...options
    }

    const response = await fetch(url, config)
    
    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`)
    }
    
    return response.json()
  }

  const getInspections = () => apiRequest('/inspections')
  const createInspection = (data) => apiRequest('/inspections', {
    method: 'POST',
    body: JSON.stringify(data)
  })
  const login = (credentials) => apiRequest('/auth/login', {
    method: 'POST',
    body: JSON.stringify(credentials)
  })

  return {
    setToken,
    getInspections,
    createInspection,
    login
  }
}
```

---

## 🧪 **TESTES RÁPIDOS**

### **1. Testar Health Check:**
```bash
curl https://rondacheck.com.br/health
```

### **2. Testar Listagem de Inspeções:**
```bash
curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjUsImVtYWlsIjoiYWRtaW5Acm9uZGFjaGVjay5jb20uYnIiLCJyb2xlIjoiQURNSU4iLCJpYXQiOjE3NTM0OTA2NDYsImV4cCI6MTc1MzQ5NDI0Nn0.qB26xcrjjklKDkwzzqEdhM84CFBKzUUTVzFoaqKcvnY" https://rondacheck.com.br/inspections
```

### **3. Testar Login:**
```bash
curl -X POST https://rondacheck.com.br/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@rondacheck.com.br","password":"admin123"}'
```

---

## 📞 **SUPORTE**

### **Em caso de problemas:**

1. **Verificar se a API está online:**
   ```bash
   curl https://rondacheck.com.br/health
   ```

2. **Verificar se o token está válido:**
   - Tokens expiram em 1 hora
   - Use o endpoint de login para obter novo token

3. **Verificar logs da API:**
   - Contatar administrador do servidor

4. **Documentação completa:**
   - Acesse: https://rondacheck.com.br/api-docs/

---

## ✅ **CHECKLIST DE IMPLEMENTAÇÃO**

- [ ] Configurar URL base como `https://rondacheck.com.br`
- [ ] Implementar autenticação JWT
- [ ] Usar HTTPS em todas as requisições
- [ ] Implementar tratamento de erros
- [ ] Testar todos os endpoints principais
- [ ] Implementar refresh de token
- [ ] Configurar CORS (já configurado na API)
- [ ] Implementar upload de fotos (se necessário)

---

## 🎉 **STATUS ATUAL**

✅ **API 100% funcional**  
✅ **Todos os endpoints testados**  
✅ **Autenticação JWT funcionando**  
✅ **HTTPS configurado**  
✅ **CORS configurado**  
✅ **Documentação Swagger disponível**  

**A API está pronta para integração com o site!** 🚀 