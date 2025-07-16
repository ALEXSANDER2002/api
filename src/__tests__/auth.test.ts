import request from 'supertest';
import app, { prisma } from '../app';

describe('Auth API', () => {
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

  it('should register a new user', async () => {
    const res = await request(app)
      .post('/auth/register')
      .send({
        email: 'register@example.com',
        name: 'Register User',
        password: 'password123',
      });
    expect(res.statusCode).toEqual(201);
    expect(res.body).toHaveProperty('user');
    expect(res.body).toHaveProperty('token');
    expect(res.body.user.email).toEqual('register@example.com');
    expect(res.body.user).not.toHaveProperty('password');
  });

  it('should not register a user with existing email', async () => {
    const uniqueEmail = `duplicate_${Date.now()}@example.com`;
    // Cria o usuário antes
    await request(app)
      .post('/auth/register')
      .send({
        email: uniqueEmail,
        name: 'Duplicate User',
        password: 'password123',
      });
    // Tenta registrar novamente
    const res = await request(app)
      .post('/auth/register')
      .send({
        email: uniqueEmail,
        name: 'Duplicate User',
        password: 'password456',
      });
    expect(res.statusCode).toEqual(409);
    expect(res.body.message).toEqual('User with this email already exists');
  });

  it('should log in an existing user', async () => {
    await request(app)
      .post('/auth/register')
      .send({
        email: 'login@example.com',
        password: 'password123',
      });

    const res = await request(app)
      .post('/auth/login')
      .send({
        email: 'login@example.com',
        password: 'password123',
      });
    expect(res.statusCode).toEqual(200);
    expect(res.body).toHaveProperty('user');
    expect(res.body).toHaveProperty('token');
    expect(res.body.user.email).toEqual('login@example.com');
    expect(res.body.user).not.toHaveProperty('password');
  });

  it('should not log in with invalid credentials', async () => {
    const res = await request(app)
      .post('/auth/login')
      .send({
        email: 'nonexistent@example.com',
        password: 'wrongpassword',
      });
    expect(res.statusCode).toEqual(401);
    expect(res.body.message).toEqual('Invalid credentials');
  });

  it('should protect routes with authentication', async () => {
    const res = await request(app).get('/users');
    expect(res.statusCode).toEqual(401);
    expect(res.body.message).toEqual('No token provided');
  });
}); 