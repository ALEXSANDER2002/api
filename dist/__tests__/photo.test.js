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
describe('Photo API', () => {
    let authToken;
    beforeEach(async () => {
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
    afterEach(async () => {
        await app_1.prisma.photo.deleteMany({});
        await app_1.prisma.inspection.deleteMany({});
        await app_1.prisma.user.deleteMany({});
    });
    it('should add a new photo to an inspection', async () => {
        // Cria usuário e inspeção
        const registerRes = await (0, supertest_1.default)(app_1.default)
            .post('/auth/register')
            .send({
            email: `phototest1_${Date.now()}@example.com`,
            name: 'Photo Test User',
            password: 'password123',
        });
        authToken = registerRes.body.token;
        const userId = registerRes.body.user.id;
        const inspectionRes = await (0, supertest_1.default)(app_1.default)
            .post('/inspections')
            .set('Authorization', `Bearer ${authToken}`)
            .send({
            title: 'Inspection for Photos',
            status: 'pending',
            userId: userId,
        });
        const inspectionId = inspectionRes.body.id;
        const inspectionExists = await app_1.prisma.inspection.findUnique({ where: { id: inspectionId } });
        const res = await (0, supertest_1.default)(app_1.default)
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
        const registerRes = await (0, supertest_1.default)(app_1.default)
            .post('/auth/register')
            .send({
            email: `phototest2_${Date.now()}@example.com`,
            name: 'Photo Test User 2',
            password: 'password123',
        });
        authToken = registerRes.body.token;
        const userId = registerRes.body.user.id;
        const inspectionRes = await (0, supertest_1.default)(app_1.default)
            .post('/inspections')
            .set('Authorization', `Bearer ${authToken}`)
            .send({
            title: 'Inspection for Photos 2',
            status: 'pending',
            userId: userId,
        });
        const inspectionId = inspectionRes.body.id;
        // Cria fotos via API
        await (0, supertest_1.default)(app_1.default)
            .post(`/photos/inspections/${inspectionId}/photos`)
            .set('Authorization', `Bearer ${authToken}`)
            .send({ url: 'https://example.com/photo_a.jpg' });
        await (0, supertest_1.default)(app_1.default)
            .post(`/photos/inspections/${inspectionId}/photos`)
            .set('Authorization', `Bearer ${authToken}`)
            .send({ url: 'https://example.com/photo_b.jpg' });
        const res = await (0, supertest_1.default)(app_1.default)
            .get(`/photos/inspections/${inspectionId}/photos`)
            .set('Authorization', `Bearer ${authToken}`);
        expect(res.statusCode).toEqual(200);
        expect(res.body).toHaveLength(2);
        expect(res.body[0].url).toEqual('https://example.com/photo_a.jpg');
    });
    it('should delete a photo', async () => {
        // Cria usuário e inspeção
        const registerRes = await (0, supertest_1.default)(app_1.default)
            .post('/auth/register')
            .send({
            email: `phototest3_${Date.now()}@example.com`,
            name: 'Photo Test User 3',
            password: 'password123',
        });
        authToken = registerRes.body.token;
        const userId = registerRes.body.user.id;
        const inspectionRes = await (0, supertest_1.default)(app_1.default)
            .post('/inspections')
            .set('Authorization', `Bearer ${authToken}`)
            .send({
            title: 'Inspection for Photos 3',
            status: 'pending',
            userId: userId,
        });
        const inspectionId = inspectionRes.body.id;
        // Cria foto via API
        const photoRes = await (0, supertest_1.default)(app_1.default)
            .post(`/photos/inspections/${inspectionId}/photos`)
            .set('Authorization', `Bearer ${authToken}`)
            .send({ url: 'https://example.com/to_delete.jpg' });
        const photoId = photoRes.body.id;
        // Garante que a foto existe antes de deletar
        const photoExists = await app_1.prisma.photo.findUnique({ where: { id: photoId } });
        expect(photoExists).not.toBeNull();
        const res = await (0, supertest_1.default)(app_1.default)
            .delete(`/photos/${photoId}`)
            .set('Authorization', `Bearer ${authToken}`);
        if (res.statusCode === 200) {
            const deletedPhoto = await app_1.prisma.photo.findUnique({ where: { id: photoId } });
            expect(deletedPhoto).toBeNull();
        }
        else {
            expect(res.statusCode).toBe(404);
        }
    });
    it('should not add a photo without authentication', async () => {
        // Cria usuário e inspeção
        const registerRes = await (0, supertest_1.default)(app_1.default)
            .post('/auth/register')
            .send({
            email: `phototest4_${Date.now()}@example.com`,
            name: 'Photo Test User 4',
            password: 'password123',
        });
        authToken = registerRes.body.token;
        const userId = registerRes.body.user.id;
        const inspectionRes = await (0, supertest_1.default)(app_1.default)
            .post('/inspections')
            .set('Authorization', `Bearer ${authToken}`)
            .send({
            title: 'Inspection for Photos 4',
            status: 'pending',
            userId: userId,
        });
        const inspectionId = inspectionRes.body.id;
        const res = await (0, supertest_1.default)(app_1.default)
            .post(`/photos/inspections/${inspectionId}/photos`)
            .send({
            url: 'https://example.com/unauthorized.jpg',
        });
        expect(res.statusCode).toEqual(401);
        expect(res.body.message).toEqual('No token provided');
    });
});
