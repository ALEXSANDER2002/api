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
    let userId;
    beforeAll(async () => {
        await app_1.prisma.photo.deleteMany({});
        await app_1.prisma.inspection.deleteMany({});
        await app_1.prisma.user.deleteMany({});
        // Register a user and get a token for authenticated requests
        const registerRes = await (0, supertest_1.default)(app_1.default)
            .post('/auth/register')
            .send({
            email: 'inspectiontest@example.com',
            name: 'Inspection Test User',
            password: 'password123',
        });
        authToken = registerRes.body.token;
        userId = registerRes.body.user.id;
    });
    afterEach(async () => {
        await app_1.prisma.photo.deleteMany({});
        await app_1.prisma.inspection.deleteMany({});
    });
    afterAll(async () => {
        await app_1.prisma.user.deleteMany({}); // Clean up the test user
        await app_1.prisma.$disconnect();
    });
    it('should create a new inspection', async () => {
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
        await app_1.prisma.inspection.create({
            data: {
                title: 'Inspection 1',
                status: 'completed',
                userId: userId,
            },
        });
        await app_1.prisma.inspection.create({
            data: {
                title: 'Inspection 2',
                status: 'pending',
                userId: userId,
            },
        });
        const res = await (0, supertest_1.default)(app_1.default)
            .get('/inspections')
            .set('Authorization', `Bearer ${authToken}`);
        expect(res.statusCode).toEqual(200);
        expect(res.body).toHaveLength(2);
        expect(res.body[0].title).toEqual('Inspection 1');
    });
    it('should get an inspection by ID', async () => {
        const inspection = await app_1.prisma.inspection.create({
            data: {
                title: 'Specific Inspection',
                status: 'pending',
                userId: userId,
            },
        });
        const res = await (0, supertest_1.default)(app_1.default)
            .get(`/inspections/${inspection.id}`)
            .set('Authorization', `Bearer ${authToken}`);
        expect(res.statusCode).toEqual(200);
        expect(res.body.title).toEqual('Specific Inspection');
    });
    it('should update an inspection', async () => {
        const inspection = await app_1.prisma.inspection.create({
            data: {
                title: 'Old Title',
                status: 'pending',
                userId: userId,
            },
        });
        const res = await (0, supertest_1.default)(app_1.default)
            .put(`/inspections/${inspection.id}`)
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
        const inspection = await app_1.prisma.inspection.create({
            data: {
                title: 'Inspection to Delete',
                status: 'pending',
                userId: userId,
            },
        });
        const res = await (0, supertest_1.default)(app_1.default)
            .delete(`/inspections/${inspection.id}`)
            .set('Authorization', `Bearer ${authToken}`);
        expect(res.statusCode).toEqual(200);
        expect(res.body.message).toEqual('Inspection deleted successfully');
        const deletedInspection = await app_1.prisma.inspection.findUnique({ where: { id: inspection.id } });
        expect(deletedInspection).toBeNull();
    });
    it('should not create an inspection without authentication', async () => {
        const res = await (0, supertest_1.default)(app_1.default)
            .post('/inspections')
            .send({
            title: 'Unauthorized Inspection',
            status: 'pending',
            userId: userId,
        });
        expect(res.statusCode).toEqual(401);
        expect(res.body.message).toEqual('No token provided');
    });
});
