"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const supertest_1 = __importDefault(require("supertest"));
const app_1 = __importStar(require("../app"));
// Helper para criar admin e obter token
async function createAdminAndLogin() {
    const email = `admin_${Date.now()}@test.com`;
    const password = 'admin123';
    const registerRes = await (0, supertest_1.default)(app_1.default)
        .post('/auth/register')
        .send({ email, password, name: 'Admin', role: 'ADMIN' });
    return { token: registerRes.body.token, userId: registerRes.body.user.id };
}
describe('Sync API', () => {
    beforeEach(async () => {
        await app_1.prisma.photo.deleteMany({});
        await app_1.prisma.inspection.deleteMany({});
        await app_1.prisma.user.deleteMany({});
    });
    afterEach(async () => {
        await app_1.prisma.photo.deleteMany({});
        await app_1.prisma.inspection.deleteMany({});
        await app_1.prisma.user.deleteMany({});
    });
    afterAll(async () => {
        await app_1.prisma.photo.deleteMany({});
        await app_1.prisma.inspection.deleteMany({});
        await app_1.prisma.user.deleteMany({});
        await app_1.prisma.$disconnect();
    });
    it('should synchronize new users, inspections, and photos', async () => {
        // Cria usuário e inspeção base
        const registerRes = await (0, supertest_1.default)(app_1.default)
            .post('/auth/register')
            .send({
            email: `synctest1_${Date.now()}@example.com`,
            name: 'Sync Test User',
            password: 'password123',
            role: 'ADMIN',
        });
        const authToken = registerRes.body.token;
        const userId = registerRes.body.user.id;
        const inspectionRes = await (0, supertest_1.default)(app_1.default)
            .post('/inspections')
            .set('Authorization', `Bearer ${authToken}`)
            .send({
            title: 'Initial Sync Inspection',
            status: 'pending',
            userId: userId,
        });
        const inspectionId = inspectionRes.body.id;
        const newUsers = [
            { email: `newuser1_${Date.now()}@sync.com`, name: 'Sync User 1', password: 'syncpass1' },
            { email: `newuser2_${Date.now()}@sync.com`, name: 'Sync User 2', password: 'syncpass2' },
        ];
        // Cria os novos usuários para obter seus IDs
        const newUser1Res = await (0, supertest_1.default)(app_1.default)
            .post('/auth/register')
            .send({ ...newUsers[0], role: 'USER' });
        const newUser1Id = newUser1Res.body.user.id;
        const newUser2Res = await (0, supertest_1.default)(app_1.default)
            .post('/auth/register')
            .send({ ...newUsers[1], role: 'USER' });
        const newUser2Id = newUser2Res.body.user.id;
        const newInspections = [
            { title: 'New Sync Inspection 1', status: 'pending', userId: newUser1Id },
            { title: 'New Sync Inspection 2', status: 'completed', userId: newUser2Id },
        ];
        // Cria inspeções para obter seus IDs
        const newInspection1Res = await (0, supertest_1.default)(app_1.default)
            .post('/inspections')
            .set('Authorization', `Bearer ${authToken}`)
            .send({ ...newInspections[0] });
        const newInspection1Id = newInspection1Res.body.id;
        const newInspection2Res = await (0, supertest_1.default)(app_1.default)
            .post('/inspections')
            .set('Authorization', `Bearer ${authToken}`)
            .send({ ...newInspections[1] });
        const newInspection2Id = newInspection2Res.body.id;
        const newPhotos = [
            { url: 'https://sync.com/photo1.jpg', inspectionId: newInspection1Id },
        ];
        const res = await (0, supertest_1.default)(app_1.default)
            .post('/sync')
            .set('Authorization', `Bearer ${authToken}`)
            .send({
            users: newUsers,
            inspections: newInspections,
            photos: newPhotos,
        });
        expect(res.statusCode).toEqual(200);
        // Os usuários sincronizados devem ser apenas os novos, não o ADMIN
        expect(res.body.syncedUsers.length).toBeGreaterThanOrEqual(2);
        expect(res.body.syncedInspections.length).toBeGreaterThanOrEqual(2);
        expect(res.body.syncedPhotos.length).toBeGreaterThanOrEqual(1);
        expect(res.body.conflicts).toHaveLength(0);
        // Verify data in DB
        const userCount = await app_1.prisma.user.count();
        expect(userCount).toBeGreaterThanOrEqual(1 + newUsers.length); // Original user + new users
        const inspectionCount = await app_1.prisma.inspection.count();
        expect(inspectionCount).toBeGreaterThanOrEqual(1 + newInspections.length); // Original inspection + new inspections
        const photoCount = await app_1.prisma.photo.count();
        expect(photoCount).toBeGreaterThanOrEqual(newPhotos.length);
    });
    it('should handle updates for existing data during synchronization', async () => {
        // Cria usuário e obtém token
        const registerRes = await (0, supertest_1.default)(app_1.default)
            .post('/auth/register')
            .send({
            email: `synctest2_${Date.now()}@example.com`,
            name: 'Sync Update User',
            password: 'password123',
            role: 'ADMIN',
        });
        const authToken = registerRes.body.token;
        const userId = registerRes.body.user.id;
        // Cria inspeção para update
        const inspectionToUpdate = await app_1.prisma.inspection.create({ data: { title: 'Old Inspection', status: 'pending', userId: userId } });
        const userToUpdate = await app_1.prisma.user.findUnique({ where: { id: userId } });
        if (!userToUpdate)
            throw new Error('Usuário para update não encontrado');
        const updatedUsers = [
            { id: userToUpdate.id, email: userToUpdate.email, name: 'New Name' },
        ];
        const updatedInspections = [
            { id: inspectionToUpdate.id, title: 'Updated Inspection', status: 'completed', userId: userId },
        ];
        const res = await (0, supertest_1.default)(app_1.default)
            .post('/sync')
            .set('Authorization', `Bearer ${authToken}`)
            .send({
            users: updatedUsers,
            inspections: updatedInspections,
        });
        expect(res.statusCode).toEqual(200);
        expect(res.body.syncedUsers).toHaveLength(1);
        expect(res.body.syncedInspections).toHaveLength(1);
        expect(res.body.conflicts).toHaveLength(0);
        const fetchedUser = await app_1.prisma.user.findUnique({ where: { id: userToUpdate.id } });
        expect(fetchedUser?.name).toEqual('New Name');
        const fetchedInspection = await app_1.prisma.inspection.findUnique({ where: { id: inspectionToUpdate.id } });
        expect(fetchedInspection?.title).toEqual('Updated Inspection');
        expect(fetchedInspection?.status).toEqual('completed');
    });
    it('should report conflicts for invalid data during synchronization', async () => {
        // Cria usuário e obtém token
        const registerRes = await (0, supertest_1.default)(app_1.default)
            .post('/auth/register')
            .send({
            email: `synctest3_${Date.now()}@example.com`,
            name: 'Sync Invalid User',
            password: 'password123',
            role: 'ADMIN',
        });
        const authToken = registerRes.body.token;
        const userId = registerRes.body.user.id;
        const invalidUsers = [
            { email: 'invalid-email', name: 'Invalid User', password: 'pass' }, // Invalid email
        ];
        const invalidInspections = [
            { title: 'Missing Status', userId: userId }, // Missing status
        ];
        const res = await (0, supertest_1.default)(app_1.default)
            .post('/sync')
            .set('Authorization', `Bearer ${authToken}`)
            .send({
            users: invalidUsers,
            inspections: invalidInspections,
        });
        expect(res.statusCode).toEqual(400); // Expect bad request due to validation errors
        expect(res.body).toHaveProperty('message');
        expect(res.body.message).toEqual('Validation error');
        expect(res.body.errors).toBeInstanceOf(Array);
        expect(res.body.errors.length).toBeGreaterThan(0);
    });
});
describe('Sync API - Erros e Bordas', () => {
    it('deve retornar 400 para payload inválido (usuário sem e-mail)', async () => {
        const { token } = await createAdminAndLogin();
        const payload = {
            users: [{ name: 'Sem Email' }],
            inspections: [],
            photos: []
        };
        const res = await (0, supertest_1.default)(app_1.default)
            .post('/sync')
            .set('Authorization', `Bearer ${token}`)
            .send(payload);
        expect(res.statusCode).toBe(400);
        expect(res.body).toHaveProperty('message', 'Validation error');
    });
    it('deve retornar conflito para e-mail duplicado', async () => {
        const { token } = await createAdminAndLogin();
        // Cria usuário previamente
        await (0, supertest_1.default)(app_1.default)
            .post('/users')
            .set('Authorization', `Bearer ${token}`)
            .send({ email: 'duplicado@email.com', password: 'senha123', name: 'Duplicado' });
        // Tenta sincronizar com mesmo e-mail
        const payload = {
            users: [{ email: 'duplicado@email.com', name: 'Outro Nome', password: 'outra' }],
            inspections: [],
            photos: []
        };
        const res = await (0, supertest_1.default)(app_1.default)
            .post('/sync')
            .set('Authorization', `Bearer ${token}`)
            .send(payload);
        expect(res.statusCode).toBe(200);
        expect(res.body.conflicts.length).toBeGreaterThan(0);
        expect(res.body.conflicts[0].type).toBe('user');
        expect(res.body.conflicts[0].error).toMatch(/already exists/i);
    });
    it('deve retornar 401 se não autenticado', async () => {
        const payload = {
            users: [{ email: 'naoautenticado@email.com', name: 'Sem Auth', password: '123' }],
            inspections: [],
            photos: []
        };
        const res = await (0, supertest_1.default)(app_1.default)
            .post('/sync')
            .send(payload);
        expect([401, 403]).toContain(res.statusCode);
    });
});
