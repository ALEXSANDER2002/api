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
describe('Inspection API', () => {
    let authToken;
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
    it('should create a new inspection', async () => {
        // Cria usuário e obtém token
        const registerRes = await (0, supertest_1.default)(app_1.default)
            .post('/auth/register')
            .send({
            email: `inspectiontest1_${Date.now()}@example.com`,
            name: 'Inspection Test User',
            password: 'password123',
        });
        authToken = registerRes.body.token;
        const userId = registerRes.body.user.id;
        const res = await (0, supertest_1.default)(app_1.default)
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
        const registerRes = await (0, supertest_1.default)(app_1.default)
            .post('/auth/register')
            .send({
            email: `inspectiontest2_${Date.now()}@example.com`,
            name: 'Inspection Test User 2',
            password: 'password123',
        });
        authToken = registerRes.body.token;
        const userId = registerRes.body.user.id;
        // Cria inspeções via API
        await (0, supertest_1.default)(app_1.default)
            .post('/inspections')
            .set('Authorization', `Bearer ${authToken}`)
            .send({
            title: 'Inspection 1',
            status: 'completed',
            userId: userId,
        });
        await (0, supertest_1.default)(app_1.default)
            .post('/inspections')
            .set('Authorization', `Bearer ${authToken}`)
            .send({
            title: 'Inspection 2',
            status: 'pending',
            userId: userId,
        });
        const res = await (0, supertest_1.default)(app_1.default)
            .get('/inspections')
            .set('Authorization', `Bearer ${authToken}`);
        expect(res.statusCode).toEqual(200);
        expect(res.body).toHaveLength(2);
        expect(res.body[0].title).toEqual('Inspection 1');
    });
    it('should get an inspection by ID', async () => {
        // Cria usuário e obtém token
        const registerRes = await (0, supertest_1.default)(app_1.default)
            .post('/auth/register')
            .send({
            email: `inspectiontest3_${Date.now()}@example.com`,
            name: 'Inspection Test User 3',
            password: 'password123',
        });
        authToken = registerRes.body.token;
        const userId = registerRes.body.user.id;
        // Cria inspeção via API
        const inspectionRes = await (0, supertest_1.default)(app_1.default)
            .post('/inspections')
            .set('Authorization', `Bearer ${authToken}`)
            .send({
            title: 'Specific Inspection',
            status: 'pending',
            userId: userId,
        });
        const inspectionId = inspectionRes.body.id;
        const res = await (0, supertest_1.default)(app_1.default)
            .get(`/inspections/${inspectionId}`)
            .set('Authorization', `Bearer ${authToken}`);
        expect(res.statusCode).toEqual(200);
        expect(res.body.title).toEqual('Specific Inspection');
    });
    it('should update an inspection', async () => {
        // Cria usuário e obtém token
        const registerRes = await (0, supertest_1.default)(app_1.default)
            .post('/auth/register')
            .send({
            email: `inspectiontest4_${Date.now()}@example.com`,
            name: 'Inspection Test User 4',
            password: 'password123',
        });
        authToken = registerRes.body.token;
        const userId = registerRes.body.user.id;
        // Cria inspeção via API
        const inspectionRes = await (0, supertest_1.default)(app_1.default)
            .post('/inspections')
            .set('Authorization', `Bearer ${authToken}`)
            .send({
            title: 'Old Title',
            status: 'pending',
            userId: userId,
        });
        const inspectionId = inspectionRes.body.id;
        const res = await (0, supertest_1.default)(app_1.default)
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
        const registerRes = await (0, supertest_1.default)(app_1.default)
            .post('/auth/register')
            .send({
            email: `inspectiontest5_${Date.now()}@example.com`,
            name: 'Inspection Test User 5',
            password: 'password123',
        });
        authToken = registerRes.body.token;
        const userId = registerRes.body.user.id;
        // Cria inspeção via API
        const inspectionRes = await (0, supertest_1.default)(app_1.default)
            .post('/inspections')
            .set('Authorization', `Bearer ${authToken}`)
            .send({
            title: 'Inspection to Delete',
            status: 'pending',
            userId: userId,
        });
        const inspectionId = inspectionRes.body.id;
        const res = await (0, supertest_1.default)(app_1.default)
            .delete(`/inspections/${inspectionId}`)
            .set('Authorization', `Bearer ${authToken}`);
        expect(res.statusCode).toEqual(200);
        expect(res.body.message).toEqual('Inspection deleted successfully');
        const deletedInspection = await app_1.prisma.inspection.findUnique({ where: { id: inspectionId } });
        expect(deletedInspection).toBeNull();
    });
    it('should not create an inspection without authentication', async () => {
        const res = await (0, supertest_1.default)(app_1.default)
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
