# Guia de Consumo da API Express (Prisma + MySQL) em Next.js

Este guia mostra como consumir sua API (documentada via Swagger) em um projeto **Next.js** moderno, usando **Tailwind CSS**, **shadcn/ui** e **pnpm** para gerenciamento de pacotes.

---

## 1. Criação do Projeto

```bash
pnpm create next-app@latest meu-projeto --typescript
cd meu-projeto
```

## 2. Instale Tailwind CSS

```bash
pnpm add -D tailwindcss postcss autoprefixer
npx tailwindcss init -p
```

Edite o `tailwind.config.js`:
```js
module.exports = {
  content: [
    './pages/**/*.{js,ts,jsx,tsx}',
    './components/**/*.{js,ts,jsx,tsx}',
    './app/**/*.{js,ts,jsx,tsx}',
  ],
  theme: { extend: {} },
  plugins: [],
}
```

No `globals.css`:
```css
@tailwind base;
@tailwind components;
@tailwind utilities;
```

## 3. Instale shadcn/ui

```bash
pnpm add @shadcn/ui
```

Consulte a [documentação oficial do shadcn/ui](https://ui.shadcn.com/docs/installation/next) para instalar os componentes desejados.

## 4. Configure o acesso à API

Crie um arquivo `.env.local`:
```
NEXT_PUBLIC_API_URL=http://localhost:3000
```

Crie um client de API genérico:
```js
// lib/api.ts
const API_URL = process.env.NEXT_PUBLIC_API_URL;

export async function apiFetch(path: string, options: RequestInit = {}) {
  const res = await fetch(`${API_URL}${path}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...(options.headers || {}),
    },
  });
  if (!res.ok) {
    const error = await res.json().catch(() => ({}));
    throw new Error(error.message || 'Erro na API');
  }
  return res.json();
}
```

## 5. Autenticação JWT

- Faça login via `/auth/login` e salve o token JWT no `localStorage` ou cookies.
- Envie o token em endpoints protegidos:
  ```js
  headers: { Authorization: `Bearer ${token}` }
  ```

Exemplo de login:
```js
// services/auth.ts
import { apiFetch } from '../lib/api';

export async function login(email: string, password: string) {
  const data = await apiFetch('/auth/login', {
    method: 'POST',
    body: JSON.stringify({ email, password }),
  });
  localStorage.setItem('token', data.token);
  return data.user;
}
```

Exemplo de requisição autenticada:
```js
export async function getUsers() {
  const token = localStorage.getItem('token');
  return apiFetch('/users', {
    headers: { Authorization: `Bearer ${token}` },
  });
}
```

## 6. Estrutura sugerida

```
/services
  api.ts         // fetch genérico
  auth.ts        // login, register, logout
  user.ts        // funções de usuário
  inspection.ts  // funções de inspeção
  photo.ts       // funções de foto
  sync.ts        // funções de sync
```

## 7. Dicas de segurança e UX

- Prefira cookies httpOnly para produção (evita XSS).
- Trate erros de API e mostre mensagens amigáveis.
- Use [SWR](https://swr.vercel.app/) ou [React Query](https://tanstack.com/query/latest) para cache e revalidação automática.
- Nunca exponha o token JWT no HTML.

## 8. Consumo no lado do servidor (SSR/SSG)

Use a URL absoluta da API em `getServerSideProps` ou `getStaticProps`:
```js
export async function getServerSideProps() {
  const res = await fetch(`${process.env.NEXT_PUBLIC_API_URL}/users`);
  const users = await res.json();
  return { props: { users } };
}
```

## 9. Referência ao Swagger

- Documentação interativa: [http://localhost:3000/api-docs](http://localhost:3000/api-docs)
- OpenAPI JSON: [http://localhost:3000/swagger.json](http://localhost:3000/swagger.json)
- Use o Swagger para ver exemplos de payloads, responses e testar endpoints.

## 10. Geração automática de client (opcional)

Se quiser gerar um client TypeScript a partir do OpenAPI:
```bash
pnpm add -D openapi-typescript-codegen
npx openapi-typescript-codegen --input http://localhost:3000/swagger.json --output ./src/api-client --client fetch
```

---

## Resumo
- Use **pnpm** para tudo.
- Centralize o acesso à API.
- Gerencie o token JWT.
- Use Tailwind e shadcn/ui para UI moderna.
- Consulte o Swagger para payloads e responses.
- Trate autenticação e erros.

Se quiser exemplos práticos de hooks, páginas ou integração com SWR/React Query, só pedir! 