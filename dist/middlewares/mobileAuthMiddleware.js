"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.mobileAuthMiddleware = void 0;
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const mobileAuthMiddleware = (req, res, next) => {
    // Verificar se é uma requisição do mobile através de header customizado
    const clientType = req.headers['x-client-type'];
    const isMobileRequest = clientType === 'mobile' || clientType === 'app';
    // Se for mobile, permite acesso sem autenticação
    if (isMobileRequest) {
        console.log('📱 Requisição mobile detectada - acesso público permitido');
        return next();
    }
    // Se for web ou não especificado, exige autenticação
    console.log('🌐 Requisição web detectada - autenticação obrigatória');
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({
            message: 'Token de autenticação obrigatório para acesso web',
            hint: 'Para acesso mobile, adicione o header: X-Client-Type: mobile'
        });
    }
    const token = authHeader.substring(7);
    try {
        const decoded = jsonwebtoken_1.default.verify(token, process.env.JWT_SECRET || 'your_jwt_secret_here');
        req.user = decoded;
        next();
    }
    catch (error) {
        return res.status(401).json({ message: 'Token inválido' });
    }
};
exports.mobileAuthMiddleware = mobileAuthMiddleware;
