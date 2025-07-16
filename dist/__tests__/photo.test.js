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
    let userId;
    let inspectionId;
    beforeAll(async () => {
        await app_1.prisma.photo.deleteMany({});
        await app_1.prisma.inspection.deleteMany({});
        await app_1.prisma.user.deleteMany({});
        // Register a user and get a token
        const registerRes = await (0, supertest_1.default)(app_1.default)
            .post('/auth/register')
            .send({
            email: 'phototest@example.com',
            name: 'Photo Test User',
            password: 'password123',
        });
        authToken = registerRes.body.token;
        userId = registerRes.body.user.id;
        // Create an inspection for photos
        const inspectionRes = await (0, supertest_1.default)(app_1.default)
            .post('/inspections')
            .set('Authorization', `Bearer ${authToken}`)
            .send({
            title: 'Inspection for Photos',
            status: 'pending',
            userId: userId,
        });
        inspectionId = inspectionRes.body.id;
    });
    afterEach(async () => {
        await app_1.prisma.photo.deleteMany({});
    });
    afterAll(async () => {
        await app_1.prisma.inspection.deleteMany({});
        await app_1.prisma.user.deleteMany({});
        await app_1.prisma.$disconnect();
    });
    it('should add a new photo to an inspection', async () => {
        const res = await (0, supertest_1.default)(app_1.default)
            .post(`/inspections/${inspectionId}/photos`)
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
        await app_1.prisma.photo.create({
            data: {
                url: 'https://example.com/photo_a.jpg',
                inspectionId: inspectionId,
            },
        });
        await app_1.prisma.photo.create({
            data: {
                url: 'https://example.com/photo_b.jpg',
                inspectionId: inspectionId,
            },
        });
        const res = await (0, supertest_1.default)(app_1.default)
            .get(`/inspections/${inspectionId}/photos`)
            .set('Authorization', `Bearer ${authToken}`);
        expect(res.statusCode).toEqual(200);
        expect(res.body).toHaveLength(2);
        expect(res.body[0].url).toEqual('https://example.com/photo_a.jpg');
    });
    it('should delete a photo', async () => {
        const photo = await app_1.prisma.photo.create({
            data: {
                url: 'https://example.com/to_delete.jpg',
                inspectionId: inspectionId,
            },
        });
        const res = await (0, supertest_1.default)(app_1.default)
            .delete(`/photos/${photo.id}`)
            .set('Authorization', `Bearer ${authToken}`);
        expect(res.statusCode).toEqual(200);
        expect(res.body.message).toEqual('Photo deleted successfully');
        const deletedPhoto = await app_1.prisma.photo.findUnique({ where: { id: photo.id } });
        expect(deletedPhoto).toBeNull();
    });
    it('should not add a photo without authentication', async () => {
        const res = await (0, supertest_1.default)(app_1.default)
            .post(`/inspections/${inspectionId}/photos`)
            .send({
            url: 'https://example.com/unauthorized.jpg',
        });
        expect(res.statusCode).toEqual(401);
        expect(res.body.message).toEqual('No token provided');
    });
});
