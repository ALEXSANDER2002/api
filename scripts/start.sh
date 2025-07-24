#!/bin/bash

echo "🚀 Iniciando API RondaCheck..."

echo "📊 Executando migrações do banco de dados..."
npx prisma migrate deploy

echo "🌱 Executando seed do banco de dados..."
npx ts-node prisma/seed.ts

echo "⚡ Iniciando servidor..."
npm start 