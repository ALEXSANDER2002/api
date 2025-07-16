import request from 'supertest';
import app, { prisma } from '../app';

describe('Inspection API', () => {
  let authToken: string;

  beforeEach(async () => {
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

  it('should create a new inspection', async () => {
    // Cria usuário e obtém token
    const registerRes = await request(app)
      .post('/auth/register')
      .send({
        email: `inspectiontest1_${Date.now()}@example.com`,
        name: 'Inspection Test User',
        password: 'password123',
      });
    authToken = registerRes.body.token;
    const userId = registerRes.body.user.id;

    const res = await request(app)
      .post('/inspections')
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        title: 'Equipment Check',
        description: 'Verify machine X',
        status: 'pending',
        userId: userId,
      });
    expect(res.statusCode).toEqual(201);
    expect(res.body).toHaveProperty('id');
    expect(res.body.title).toEqual('Equipment Check');
  });

  it('should get all inspections', async () => {
    // Cria usuário e obtém token
    const registerRes = await request(app)
      .post('/auth/register')
      .send({
        email: `inspectiontest2_${Date.now()}@example.com`,
        name: 'Inspection Test User 2',
        password: 'password123',
      });
    authToken = registerRes.body.token;
    const userId = registerRes.body.user.id;

    // Cria inspeções via API
    await request(app)
      .post('/inspections')
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        title: 'Inspection 1',
        status: 'completed',
        userId: userId,
      });
    await request(app)
      .post('/inspections')
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        title: 'Inspection 2',
        status: 'pending',
        userId: userId,
      });

    const res = await request(app)
      .get('/inspections')
      .set('Authorization', `Bearer ${authToken}`);
    expect(res.statusCode).toEqual(200);
    expect(res.body).toHaveLength(2);
    expect(res.body[0].title).toEqual('Inspection 1');
  });

  it('should get an inspection by ID', async () => {
    // Cria usuário e obtém token
    const registerRes = await request(app)
      .post('/auth/register')
      .send({
        email: `inspectiontest3_${Date.now()}@example.com`,
        name: 'Inspection Test User 3',
        password: 'password123',
      });
    authToken = registerRes.body.token;
    const userId = registerRes.body.user.id;

    // Cria inspeção via API
    const inspectionRes = await request(app)
      .post('/inspections')
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        title: 'Specific Inspection',
        status: 'pending',
        userId: userId,
      });
    const inspectionId = inspectionRes.body.id;

    const res = await request(app)
      .get(`/inspections/${inspectionId}`)
      .set('Authorization', `Bearer ${authToken}`);
    expect(res.statusCode).toEqual(200);
    expect(res.body.title).toEqual('Specific Inspection');
  });

  it('should update an inspection', async () => {
    // Cria usuário e obtém token
    const registerRes = await request(app)
      .post('/auth/register')
      .send({
        email: `inspectiontest4_${Date.now()}@example.com`,
        name: 'Inspection Test User 4',
        password: 'password123',
      });
    authToken = registerRes.body.token;
    const userId = registerRes.body.user.id;

    // Cria inspeção via API
    const inspectionRes = await request(app)
      .post('/inspections')
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        title: 'Old Title',
        status: 'pending',
        userId: userId,
      });
    const inspectionId = inspectionRes.body.id;

    const res = await request(app)
      .put(`/inspections/${inspectionId}`)
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        title: 'Updated Title',
        status: 'completed',
      });
    expect(res.statusCode).toEqual(200);
    expect(res.body.title).toEqual('Updated Title');
    expect(res.body.status).toEqual('completed');
  });

  it('should delete an inspection', async () => {
    // Cria usuário e obtém token
    const registerRes = await request(app)
      .post('/auth/register')
      .send({
        email: `inspectiontest5_${Date.now()}@example.com`,
        name: 'Inspection Test User 5',
        password: 'password123',
      });
    authToken = registerRes.body.token;
    const userId = registerRes.body.user.id;

    // Cria inspeção via API
    const inspectionRes = await request(app)
      .post('/inspections')
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        title: 'Inspection to Delete',
        status: 'pending',
        userId: userId,
      });
    const inspectionId = inspectionRes.body.id;

    const res = await request(app)
      .delete(`/inspections/${inspectionId}`)
      .set('Authorization', `Bearer ${authToken}`);
    expect(res.statusCode).toEqual(200);
    expect(res.body.message).toEqual('Inspection deleted successfully');

    const deletedInspection = await prisma.inspection.findUnique({ where: { id: inspectionId } });
    expect(deletedInspection).toBeNull();
  });

  it('should not create an inspection without authentication', async () => {
    const res = await request(app)
      .post('/inspections')
      .send({
        title: 'Unauthorized Inspection',
        status: 'pending',
        userId: 1, // Assuming a default user ID for this test
      });
    expect(res.statusCode).toEqual(401);
    expect(res.body.message).toEqual('No token provided');
  });
}); 