#!/bin/bash

echo "🚀 Iniciando API RondaCheck..."

echo "📊 Executando migrações do banco de dados..."
npx prisma migrate deploy

echo "🌱 Executando seed do banco de dados..."
npm run seed

echo "⚡ Iniciando servidor..."
npm start 