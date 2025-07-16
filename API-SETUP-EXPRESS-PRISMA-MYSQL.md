# Guia de Setup e Rotas – API Express + Prisma + MySQL

## 1. Setup Inicial

### Pré-requisitos
- Node.js (LTS)
- MySQL rodando
- Editor de código (VSCode recomendado)

### Instalação
```bash
npm init -y
npm install express cors dotenv
npm install -D typescript ts-node-dev @types/express @types/node
npm install prisma --save-dev
npm install @prisma/client
npx tsc --init
npx prisma init
```

### Configuração do TypeScript (`tsconfig.json`)
```json
{
  "target": "ES2020",
  "module": "commonjs",
  "outDir": "./dist",
  "rootDir": "./src",
  "strict": true,
  "esModuleInterop": true
}
```

### Configuração do Prisma (`prisma/schema.prisma`)
```prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "mysql"
  url      = env("DATABASE_URL")
}

model User {
  id        Int      @id @default(autoincrement())
  email     String   @unique
  name      String?
  createdAt DateTime @default(now())
  inspections Inspection[]
}

model Inspection {
  id          Int      @id @default(autoincrement())
  title       String
  description String?
  status      String   // exemplo: 'pending', 'completed', 'synced'
  userId      Int
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
  photos      Photo[]
  user        User     @relation(fields: [userId], references: [id])
}

model Photo {
  id           Int      @id @default(autoincrement())
  url          String
  inspectionId Int
  createdAt    DateTime @default(now())
  inspection   Inspection @relation(fields: [inspectionId], references: [id])
}
```

### Variáveis de Ambiente (`.env`)
```
DATABASE_URL="mysql://usuario:senha@localhost:3306/nome_do_banco"
```

### Migração do Banco
```bash
npx prisma migrate dev --name init
```

---

## 2. Estrutura de Pastas Recomendada

```
minha-api/
  ├─ prisma/
  │    └─ schema.prisma
  ├─ src/
  │    ├─ index.ts
  │    └─ routes/
  │         ├─ userRoutes.ts
  │         └─ inspectionRoutes.ts
  ├─ .env
  ├─ package.json
  └─ tsconfig.json
```

---

## 3. Scripts no `package.json`

```json
"scripts": {
  "dev": "ts-node-dev --respawn --transpile-only src/index.ts",
  "build": "tsc",
  "start": "node dist/index.js",
  "prisma": "prisma"
}
```

---

## 4. Rotas e Payloads

### Usuários

#### Criar Usuário
- **POST** `/users`
- **Payload:**
```json
{
  "email": "teste@exemplo.com",
  "name": "Fulano"
}
```
- **Resposta:**
```json
{
  "id": 1,
  "email": "teste@exemplo.com",
  "name": "Fulano",
  "createdAt": "2024-06-01T12:00:00.000Z"
}
```

#### Listar Usuários
- **GET** `/users`
- **Resposta:**
```json
[
  {
    "id": 1,
    "email": "teste@exemplo.com",
    "name": "Fulano",
    "createdAt": "2024-06-01T12:00:00.000Z"
  }
]
```

#### Buscar Usuário por ID
- **GET** `/users/:id`
- **Resposta:**
```json
{
  "id": 1,
  "email": "teste@exemplo.com",
  "name": "Fulano",
  "createdAt": "2024-06-01T12:00:00.000Z"
}
```

#### Atualizar Usuário
- **PUT** `/users/:id`
- **Payload:**
```json
{
  "name": "Novo Nome"
}
```
- **Resposta:**
```json
{
  "id": 1,
  "email": "teste@exemplo.com",
  "name": "Novo Nome",
  "createdAt": "2024-06-01T12:00:00.000Z"
}
```

#### Deletar Usuário
- **DELETE** `/users/:id`
- **Resposta:**
```json
{
  "message": "Usuário deletado com sucesso"
}
```

---

### Inspeções

#### Criar Inspeção
- **POST** `/inspections`
- **Payload:**
```json
{
  "title": "Inspeção de Equipamento",
  "description": "Verificar funcionamento do equipamento X",
  "status": "pending",
  "userId": 1
}
```
- **Resposta:**
```json
{
  "id": 1,
  "title": "Inspeção de Equipamento",
  "description": "Verificar funcionamento do equipamento X",
  "status": "pending",
  "userId": 1,
  "createdAt": "2024-06-01T12:00:00.000Z",
  "updatedAt": "2024-06-01T12:00:00.000Z"
}
```

#### Listar Inspeções
- **GET** `/inspections`
- **Resposta:**
```json
[
  {
    "id": 1,
    "title": "Inspeção de Equipamento",
    "description": "Verificar funcionamento do equipamento X",
    "status": "pending",
    "userId": 1,
    "createdAt": "2024-06-01T12:00:00.000Z",
    "updatedAt": "2024-06-01T12:00:00.000Z"
  }
]
```

#### Buscar Inspeção por ID
- **GET** `/inspections/:id`
- **Resposta:**
```json
{
  "id": 1,
  "title": "Inspeção de Equipamento",
  "description": "Verificar funcionamento do equipamento X",
  "status": "pending",
  "userId": 1,
  "createdAt": "2024-06-01T12:00:00.000Z",
  "updatedAt": "2024-06-01T12:00:00.000Z"
}
```

#### Atualizar Inspeção
- **PUT** `/inspections/:id`
- **Payload:**
```json
{
  "title": "Novo Título",
  "description": "Nova descrição",
  "status": "completed"
}
```
- **Resposta:**
```json
{
  "id": 1,
  "title": "Novo Título",
  "description": "Nova descrição",
  "status": "completed",
  "userId": 1,
  "createdAt": "2024-06-01T12:00:00.000Z",
  "updatedAt": "2024-06-01T13:00:00.000Z"
}
```

#### Deletar Inspeção
- **DELETE** `/inspections/:id`
- **Resposta:**
```json
{
  "message": "Inspeção deletada com sucesso"
}
```

---

### Fotos (relacionadas à inspeção)

#### Adicionar Foto
- **POST** `/inspections/:inspectionId/photos`
- **Payload:**
```json
{
  "url": "https://meuservidor.com/fotos/foto1.jpg"
}
```
- **Resposta:**
```json
{
  "id": 1,
  "url": "https://meuservidor.com/fotos/foto1.jpg",
  "inspectionId": 1,
  "createdAt": "2024-06-01T12:00:00.000Z"
}
```

#### Listar Fotos de uma Inspeção
- **GET** `/inspections/:inspectionId/photos`
- **Resposta:**
```json
[
  {
    "id": 1,
    "url": "https://meuservidor.com/fotos/foto1.jpg",
    "inspectionId": 1,
    "createdAt": "2024-06-01T12:00:00.000Z"
  }
]
```

#### Deletar Foto
- **DELETE** `/photos/:id`
- **Resposta:**
```json
{
  "message": "Foto deletada com sucesso"
}
```

---

### Sincronização (Exemplo de Endpoint)

#### Sincronizar Dados do App
- **POST** `/sync`
- **Payload:**
```json
{
  "users": [ /* array de usuários pendentes */ ],
  "inspections": [ /* array de inspeções pendentes */ ],
  "photos": [ /* array de fotos pendentes */ ]
}
```
- **Resposta:**
```json
{
  "syncedUsers": [ /* usuários sincronizados */ ],
  "syncedInspections": [ /* inspeções sincronizadas */ ],
  "syncedPhotos": [ /* fotos sincronizadas */ ],
  "conflicts": [ /* conflitos detectados, se houver */ ]
}
```

**Dica:**
- O backend deve tratar conflitos (ex: se inspeção já foi alterada no site, prevalece o dado do site).
- Retorne detalhes dos conflitos para o app mostrar ao usuário.

---

## 5. Dicas de Boas Práticas
- Separe controllers, services e rotas para maior organização.
- Use variáveis de ambiente para credenciais e configs sensíveis.
- Implemente autenticação (JWT) para rotas protegidas.
- Adicione validação de payloads (ex: Zod, Joi).
- Use middlewares para tratamento de erros.
- Documente as rotas (ex: Swagger, Redoc).
- Faça testes automatizados (Jest, Supertest).
- Considere Docker para padronizar ambientes.
- Para fotos, use serviços de storage (ex: S3, Cloudinary) e salve apenas a URL no banco.
- Para sincronização, registre data/hora da última sync e status de cada registro.

---

## 6. Próximos Passos
- Adicionar autenticação e autorização.
- Implementar endpoints de sincronização robustos.
- Tratar conflitos de sincronização conforme regras do seu app.
- Monitorar logs e performance.
- Adicionar testes automatizados.

---

## 7. Referências
- [Documentação Express](https://expressjs.com/pt-br/)
- [Documentação Prisma](https://www.prisma.io/docs)
- [Documentação MySQL](https://dev.mysql.com/doc/)
- [TypeScript](https://www.typescriptlang.org/)

---

Se quiser exemplos de controllers, services, middlewares ou endpoints de sync, só pedir! 

---

## 8. Documentação Automática com Swagger (OpenAPI)

### Por que usar?
O Swagger permite documentar e testar sua API de forma interativa, facilitando o entendimento e integração por outros devs e pelo frontend.

### Instalação
```bash
npm install swagger-ui-express swagger-jsdoc
```

### Configuração Básica
No seu `src/index.ts`:

```typescript
import swaggerUi from 'swagger-ui-express';
import swaggerJsdoc from 'swagger-jsdoc';

const swaggerOptions = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'API de Inspeções',
      version: '1.0.0',
      description: 'Documentação da API Express + Prisma + MySQL',
    },
    servers: [
      { url: 'http://localhost:3000' }
    ],
  },
  apis: ['./src/routes/*.ts'], // Caminho dos arquivos de rotas
};

const swaggerSpec = swaggerJsdoc(swaggerOptions);

app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));
```

Acesse a documentação em: [http://localhost:3000/api-docs](http://localhost:3000/api-docs)

### Exemplo de Anotação em Rotas (`src/routes/userRoutes.ts`)

```typescript
/**
 * @swagger
 * /users:
 *   get:
 *     summary: Lista todos os usuários
 *     responses:
 *       200:
 *         description: Lista de usuários
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/User'
 *   post:
 *     summary: Cria um novo usuário
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/UserInput'
 *     responses:
 *       201:
 *         description: Usuário criado
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/User'
 */
```

### Exemplo de Schemas no Swagger
No topo do seu arquivo de rotas ou em um arquivo separado:

```typescript
/**
 * @swagger
 * components:
 *   schemas:
 *     User:
 *       type: object
 *       properties:
 *         id:
 *           type: integer
 *         email:
 *           type: string
 *         name:
 *           type: string
 *         createdAt:
 *           type: string
 *           format: date-time
 *     UserInput:
 *       type: object
 *       properties:
 *         email:
 *           type: string
 *         name:
 *           type: string
 *       required:
 *         - email
 */
```

Repita o mesmo padrão para Inspections e Photos.

### Dicas
- Sempre atualize as anotações ao criar/alterar rotas.
- Você pode dividir a documentação em múltiplos arquivos.
- O Swagger também permite testar endpoints diretamente pelo navegador.

---

Se quiser exemplos prontos de anotações para inspeções ou fotos, só pedir! 