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
const app_1 = __importStar(require("../app")); // Importe app como default e prisma nomeado
describe('User API', () => {
    beforeAll(async () => {
        // Limpa o banco de dados antes de todos os testes
        await app_1.prisma.user.deleteMany({});
    });
    afterEach(async () => {
        // Limpa os usuários após cada teste
        await app_1.prisma.user.deleteMany({});
    });
    afterAll(async () => {
        await app_1.prisma.$disconnect();
    });
    it('should create a new user', async () => {
        const res = await (0, supertest_1.default)(app_1.default)
            .post('/users')
            .send({
            email: 'test@example.com',
            name: 'Test User',
            password: 'password123',
        });
        expect(res.statusCode).toEqual(201);
        expect(res.body).toHaveProperty('id');
        expect(res.body.email).toEqual('test@example.com');
    });
    it('should not create a user with existing email', async () => {
        await app_1.prisma.user.create({
            data: {
                email: 'existing@example.com',
                name: 'Existing User',
                password: 'password123',
            },
        });
        const res = await (0, supertest_1.default)(app_1.default)
            .post('/users')
            .send({
            email: 'existing@example.com',
            name: 'Another User',
            password: 'password123',
        });
        expect(res.statusCode).toEqual(409);
        expect(res.body.message).toEqual('User with this email already exists.');
    });
    // Mais testes para GET, PUT, DELETE de usuários seriam adicionados aqui.
});
