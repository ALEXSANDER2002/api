"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.prisma = void 0;
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
require("dotenv/config"); // Importa e configura o dotenv
const client_1 = require("@prisma/client");
const authRoutes_1 = __importDefault(require("./routes/authRoutes"));
const userRoutes_1 = __importDefault(require("./routes/userRoutes"));
const inspectionRoutes_1 = __importDefault(require("./routes/inspectionRoutes"));
const photoRoutes_1 = __importDefault(require("./routes/photoRoutes"));
const syncRoutes_1 = __importDefault(require("./routes/syncRoutes"));
const errorHandler_1 = require("./middlewares/errorHandler");
const app = (0, express_1.default)();
const prisma = new client_1.PrismaClient();
exports.prisma = prisma;
// Middlewares
app.use((0, cors_1.default)());
app.use(express_1.default.json());
// Routes
app.use('/auth', authRoutes_1.default);
app.use('/users', userRoutes_1.default);
app.use('/inspections', inspectionRoutes_1.default);
app.use('/photos', photoRoutes_1.default);
app.use('/sync', syncRoutes_1.default);
// Error handling middleware
app.use(errorHandler_1.errorHandler);
// Test Route
app.get('/', (req, res) => {
    res.send('API is running!');
});
exports.default = app; // Exportando a instância do app 
