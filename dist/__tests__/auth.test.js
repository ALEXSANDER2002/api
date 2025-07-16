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
describe('Auth API', () => {
    beforeAll(async () => {
        await app_1.prisma.user.deleteMany({});
    });
    afterEach(async () => {
        await app_1.prisma.user.deleteMany({});
    });
    afterAll(async () => {
        await app_1.prisma.$disconnect();
    });
    it('should register a new user', async () => {
        const res = await (0, supertest_1.default)(app_1.default)
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
        await (0, supertest_1.default)(app_1.default)
            .post('/auth/register')
            .send({
            email: 'duplicate@example.com',
            password: 'password123',
        });
        const res = await (0, supertest_1.default)(app_1.default)
            .post('/auth/register')
            .send({
            email: 'duplicate@example.com',
            password: 'password456',
        });
        expect(res.statusCode).toEqual(409);
        expect(res.body.message).toEqual('User with this email already exists');
    });
    it('should log in an existing user', async () => {
        await (0, supertest_1.default)(app_1.default)
            .post('/auth/register')
            .send({
            email: 'login@example.com',
            password: 'password123',
        });
        const res = await (0, supertest_1.default)(app_1.default)
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
        const res = await (0, supertest_1.default)(app_1.default)
            .post('/auth/login')
            .send({
            email: 'nonexistent@example.com',
            password: 'wrongpassword',
        });
        expect(res.statusCode).toEqual(401);
        expect(res.body.message).toEqual('Invalid credentials');
    });
    it('should protect routes with authentication', async () => {
        const res = await (0, supertest_1.default)(app_1.default).get('/users');
        expect(res.statusCode).toEqual(401);
        expect(res.body.message).toEqual('No token provided');
    });
});
