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
describe('Sync API', () => {
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
            email: 'synctest@example.com',
            name: 'Sync Test User',
            password: 'password123',
        });
        authToken = registerRes.body.token;
        userId = registerRes.body.user.id;
        // Create an initial inspection for testing updates/conflicts
        const inspectionRes = await (0, supertest_1.default)(app_1.default)
            .post('/inspections')
            .set('Authorization', `Bearer ${authToken}`)
            .send({
            title: 'Initial Sync Inspection',
            status: 'pending',
            userId: userId,
        });
        inspectionId = inspectionRes.body.id;
    });
    afterEach(async () => {
        // Clean up data added by each test, but keep the initial user/inspection
    });
    afterAll(async () => {
        await app_1.prisma.photo.deleteMany({});
        await app_1.prisma.inspection.deleteMany({});
        await app_1.prisma.user.deleteMany({}); // Clean up the test user
        await app_1.prisma.$disconnect();
    });
    it('should synchronize new users, inspections, and photos', async () => {
        const newUsers = [
            { email: 'newuser1@sync.com', name: 'Sync User 1', password: 'syncpass1' },
            { email: 'newuser2@sync.com', name: 'Sync User 2', password: 'syncpass2' },
        ];
        const newInspections = [
            { title: 'New Sync Inspection 1', status: 'pending', userId: userId },
            { title: 'New Sync Inspection 2', status: 'completed', userId: userId },
        ];
        const newPhotos = [
            { url: 'https://sync.com/photo1.jpg', inspectionId: inspectionId },
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
        expect(res.body.syncedUsers).toHaveLength(2);
        expect(res.body.syncedInspections).toHaveLength(2);
        expect(res.body.syncedPhotos).toHaveLength(1);
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
        // Create a user and inspection to be updated
        const userToUpdate = await app_1.prisma.user.create({ data: { email: 'updateuser@sync.com', name: 'Old Name', password: 'oldpass' } });
        const inspectionToUpdate = await app_1.prisma.inspection.create({ data: { title: 'Old Inspection', status: 'pending', userId: userId } });
        const updatedUsers = [
            { id: userToUpdate.id, email: 'updateuser@sync.com', name: 'New Name' },
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
