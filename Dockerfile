# Use a imagem oficial do Node.js como base
FROM node:20-alpine

# Define o diretório de trabalho dentro do contêiner
WORKDIR /app

# Copia os arquivos package.json e pnpm-lock.yaml para o diretório de trabalho
COPY package.json ./pnpm-lock.yaml* ./

# Instala as dependências usando pnpm
# Use --frozen-lockfile para garantir que as dependências sejam exatamente como no lockfile
RUN pnpm install --frozen-lockfile

# Copia o restante do código da aplicação para o diretório de trabalho
COPY . .

# Gera o Prisma Client dentro do contêiner
RUN npx prisma generate

# Constrói a aplicação TypeScript
RUN npm run build

# Expõe a porta em que a aplicação será executada
EXPOSE 3000

# Define o comando para iniciar a aplicação em produção
CMD ["npm", "start"] 