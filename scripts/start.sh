#!/bin/bash

echo "🚀 Iniciando API RondaCheck..."

echo "📊 Executando migrações do banco de dados..."
npx prisma migrate deploy

echo "🌱 Executando seed do banco de dados..."
node -e "
const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');

const prisma = new PrismaClient();

async function createDefaultUsers() {
  try {
    // Verificar se admin já existe
    const existingAdmin = await prisma.user.findUnique({
      where: { email: 'admin@rondacheck.com.br' }
    });

    if (!existingAdmin) {
      const hashedPassword = await bcrypt.hash('admin123', 10);
      const admin = await prisma.user.create({
        data: {
          name: 'Administrador',
          email: 'admin@rondacheck.com.br',
          password: hashedPassword,
          role: 'ADMIN'
        }
      });
      console.log('✅ Admin criado:', admin.email);
    } else {
      console.log('ℹ️ Admin já existe:', existingAdmin.email);
    }

    // Verificar se usuário teste já existe
    const existingTest = await prisma.user.findUnique({
      where: { email: 'teste@rondacheck.com.br' }
    });

    if (!existingTest) {
      const hashedPassword = await bcrypt.hash('123456', 10);
      const testUser = await prisma.user.create({
        data: {
          name: 'Usuário Teste',
          email: 'teste@rondacheck.com.br',
          password: hashedPassword,
          role: 'USER'
        }
      });
      console.log('✅ Usuário teste criado:', testUser.email);
    } else {
      console.log('ℹ️ Usuário teste já existe:', existingTest.email);
    }

  } catch (error) {
    console.error('❌ Erro ao criar usuários:', error);
  } finally {
    await prisma.\$disconnect();
  }
}

createDefaultUsers();
"

echo "⚡ Iniciando servidor..."
npm start 