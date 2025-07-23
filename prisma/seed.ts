import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Iniciando seed do banco de dados...');

  // Verificar se o usuário admin já existe
  const existingAdmin = await prisma.user.findUnique({
    where: { email: 'admin@rondacheck.com.br' }
  });

  if (!existingAdmin) {
    // Criar usuário admin padrão
    const hashedPassword = await bcrypt.hash('admin123', 10);
    
    const adminUser = await prisma.user.create({
      data: {
        name: 'Administrador',
        email: 'admin@rondacheck.com.br',
        password: hashedPassword,
        role: 'ADMIN'
      }
    });

    console.log('✅ Usuário admin criado:', {
      id: adminUser.id,
      name: adminUser.name,
      email: adminUser.email,
      role: adminUser.role
    });
  } else {
    console.log('ℹ️ Usuário admin já existe:', existingAdmin.email);
  }

  // Verificar se existe usuário de teste
  const existingTestUser = await prisma.user.findUnique({
    where: { email: 'teste@rondacheck.com.br' }
  });

  if (!existingTestUser) {
    // Criar usuário de teste
    const hashedPassword = await bcrypt.hash('123456', 10);
    
    const testUser = await prisma.user.create({
      data: {
        name: 'Usuário Teste',
        email: 'teste@rondacheck.com.br',
        password: hashedPassword,
        role: 'USER'
      }
    });

    console.log('✅ Usuário teste criado:', {
      id: testUser.id,
      name: testUser.name,
      email: testUser.email,
      role: testUser.role
    });
  } else {
    console.log('ℹ️ Usuário teste já existe:', existingTestUser.email);
  }

  console.log('🎉 Seed concluído com sucesso!');
}

main()
  .catch((e) => {
    console.error('❌ Erro durante o seed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  }); 