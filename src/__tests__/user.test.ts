import request from 'supertest';
import app, { prisma } from '../app'; // Importe app como default e prisma nomeado

describe('User API', () => {
  beforeAll(async () => {
    await prisma.photo.deleteMany({});
    await prisma.inspection.deleteMany({});
    await prisma.user.deleteMany({});
  });

  afterEach(async () => {
    await prisma.photo.deleteMany({});
    await prisma.inspection.deleteMany({});
    await prisma.user.deleteMany({});
  });

  afterAll(async () => {
    await prisma.photo.deleteMany({});
    await prisma.inspection.deleteMany({});
    await prisma.user.deleteMany({});
    await prisma.$disconnect();
  });

  it('should create a new user', async () => {
    const res = await request(app)
      .post('/users')
      .send({
        email: 'test@example.com',
        name: 'Test User',
        password: 'password123',
      });
    expect(res.statusCode).toEqual(201);
    expect(res.body).toHaveProperty('id');
    expect(res.body.email).toEqual('test@example.com');
  });

  it('should not create a user with existing email', async () => {
    await prisma.user.create({
      data: {
        email: 'existing@example.com',
        name: 'Existing User',
        password: 'password123',
      },
    });

    const res = await request(app)
      .post('/users')
      .send({
        email: 'existing@example.com',
        name: 'Another User',
        password: 'password123',
      });
    expect(res.statusCode).toEqual(409);
    expect(res.body.message).toEqual('User with this email already exists');
  });

  // Mais testes para GET, PUT, DELETE de usuários seriam adicionados aqui.
}); 