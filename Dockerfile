# Use a imagem oficial do Node.js como base
FROM node:20-alpine

# Define o diretório de trabalho dentro do contêiner
WORKDIR /app

# Copia os arquivos package.json e pnpm-lock.yaml para o diretório de trabalho
COPY package.json ./pnpm-lock.yaml* ./

# Instala o pnpm globalmente
RUN npm install -g pnpm

# Instala as dependências usando pnpm (incluindo devDependencies)
RUN pnpm install --no-frozen-lockfile --prod=false

# Copia o restante do código da aplicação para o diretório de trabalho
COPY . .

# Gera o Prisma Client dentro do contêiner
RUN pnpm prisma generate

# Constrói a aplicação TypeScript
RUN npm run build

# Torna executável o script de inicialização
RUN chmod +x scripts/start.sh

# Expõe a porta em que a aplicação será executada
EXPOSE 3000

# Define o comando para iniciar a aplicação em produção
CMD ["sh", "./scripts/start.sh"] 