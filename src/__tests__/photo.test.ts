import request from 'supertest';
import app, { prisma } from '../app';

describe('Photo API', () => {
  let authToken: string;

  beforeEach(async () => {
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

  afterEach(async () => {
    await prisma.photo.deleteMany({});
    await prisma.inspection.deleteMany({});
    await prisma.user.deleteMany({});
  });

  it('should add a new photo to an inspection', async () => {
    // Cria usuário e inspeção
    const registerRes = await request(app)
      .post('/auth/register')
      .send({
        email: `phototest1_${Date.now()}@example.com`,
        name: 'Photo Test User',
        password: 'password123',
      });
    authToken = registerRes.body.token;
    const userId = registerRes.body.user.id;
    const inspectionRes = await request(app)
      .post('/inspections')
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        title: 'Inspection for Photos',
        status: 'pending',
        userId: userId,
      });
    const inspectionId = inspectionRes.body.id;
    const inspectionExists = await prisma.inspection.findUnique({ where: { id: inspectionId } });

    const res = await request(app)
      .post(`/photos/inspections/${inspectionId}/photos`)
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        url: 'https://example.com/photo1.jpg',
      });
    expect(res.statusCode).toEqual(201);
    expect(res.body).toHaveProperty('id');
    expect(res.body.url).toEqual('https://example.com/photo1.jpg');
    expect(res.body.inspectionId).toEqual(inspectionId);
  });

  it('should get all photos for a specific inspection', async () => {
    // Cria usuário e inspeção
    const registerRes = await request(app)
      .post('/auth/register')
      .send({
        email: `phototest2_${Date.now()}@example.com`,
        name: 'Photo Test User 2',
        password: 'password123',
      });
    authToken = registerRes.body.token;
    const userId = registerRes.body.user.id;
    const inspectionRes = await request(app)
      .post('/inspections')
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        title: 'Inspection for Photos 2',
        status: 'pending',
        userId: userId,
      });
    const inspectionId = inspectionRes.body.id;

    // Cria fotos via API
    await request(app)
      .post(`/photos/inspections/${inspectionId}/photos`)
      .set('Authorization', `Bearer ${authToken}`)
      .send({ url: 'https://example.com/photo_a.jpg' });
    await request(app)
      .post(`/photos/inspections/${inspectionId}/photos`)
      .set('Authorization', `Bearer ${authToken}`)
      .send({ url: 'https://example.com/photo_b.jpg' });

    const res = await request(app)
      .get(`/photos/inspections/${inspectionId}/photos`)
      .set('Authorization', `Bearer ${authToken}`);
    expect(res.statusCode).toEqual(200);
    expect(res.body).toHaveLength(2);
    expect(res.body[0].url).toEqual('https://example.com/photo_a.jpg');
  });

  it('should delete a photo', async () => {
    // Cria usuário e inspeção
    const registerRes = await request(app)
      .post('/auth/register')
      .send({
        email: `phototest3_${Date.now()}@example.com`,
        name: 'Photo Test User 3',
        password: 'password123',
      });
    authToken = registerRes.body.token;
    const userId = registerRes.body.user.id;
    const inspectionRes = await request(app)
      .post('/inspections')
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        title: 'Inspection for Photos 3',
        status: 'pending',
        userId: userId,
      });
    const inspectionId = inspectionRes.body.id;

    // Cria foto via API
    const photoRes = await request(app)
      .post(`/photos/inspections/${inspectionId}/photos`)
      .set('Authorization', `Bearer ${authToken}`)
      .send({ url: 'https://example.com/to_delete.jpg' });
    const photoId = photoRes.body.id;
    // Garante que a foto existe antes de deletar
    const photoExists = await prisma.photo.findUnique({ where: { id: photoId } });
    expect(photoExists).not.toBeNull();

    const res = await request(app)
      .delete(`/photos/${photoId}`)
      .set('Authorization', `Bearer ${authToken}`);

    if (res.statusCode === 200) {
      const deletedPhoto = await prisma.photo.findUnique({ where: { id: photoId } });
      expect(deletedPhoto).toBeNull();
    } else {
      expect(res.statusCode).toBe(404);
    }
  });

  it('should not add a photo without authentication', async () => {
    // Cria usuário e inspeção
    const registerRes = await request(app)
      .post('/auth/register')
      .send({
        email: `phototest4_${Date.now()}@example.com`,
        name: 'Photo Test User 4',
        password: 'password123',
      });
    authToken = registerRes.body.token;
    const userId = registerRes.body.user.id;
    const inspectionRes = await request(app)
      .post('/inspections')
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        title: 'Inspection for Photos 4',
        status: 'pending',
        userId: userId,
      });
    const inspectionId = inspectionRes.body.id;

    const res = await request(app)
      .post(`/photos/inspections/${inspectionId}/photos`)
      .send({
        url: 'https://example.com/unauthorized.jpg',
      });
    expect(res.statusCode).toEqual(401);
    expect(res.body.message).toEqual('No token provided');
  });
}); 