"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.prisma = void 0;
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
require("dotenv/config");
const prisma_1 = __importDefault(require("./prisma"));
exports.prisma = prisma_1.default;
const authRoutes_1 = __importDefault(require("./routes/authRoutes"));
const userRoutes_1 = __importDefault(require("./routes/userRoutes"));
const inspectionRoutes_1 = __importDefault(require("./routes/inspectionRoutes"));
const photoRoutes_1 = __importDefault(require("./routes/photoRoutes"));
const syncRoutes_1 = __importDefault(require("./routes/syncRoutes"));
const publicRoutes_1 = __importDefault(require("./routes/publicRoutes"));
const errorHandler_1 = require("./middlewares/errorHandler");
const app = (0, express_1.default)();
// CORS LIBERADO PARA TUDO - CONFIGURAÇÃO SIMPLES E EFETIVA
app.use((0, cors_1.default)({
    origin: true,
    credentials: false,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS', 'PATCH'],
    allowedHeaders: ['*'],
    exposedHeaders: ['Content-Length', 'X-Requested-With']
}));
// Middlewares básicos
app.use(express_1.default.json({ limit: '10mb' }));
app.use(express_1.default.urlencoded({ extended: true, limit: '10mb' }));
// Rota raiz
app.get('/', (req, res) => {
    res.send('API is running!');
});
// Middleware de log simplificado
app.use((req, res, next) => {
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.path} - Origin: ${req.headers.origin || 'none'}`);
    next();
});
// Rotas
app.use('/public', publicRoutes_1.default);
app.use('/auth', authRoutes_1.default);
app.use('/users', userRoutes_1.default);
app.use('/photos', photoRoutes_1.default);
app.use('/inspections', inspectionRoutes_1.default);
app.use('/sync', syncRoutes_1.default);
// Error handling
app.use(errorHandler_1.errorHandler);
exports.default = app;
