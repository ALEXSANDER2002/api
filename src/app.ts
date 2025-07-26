import express, { Request, Response, NextFunction } from 'express';
import cors from 'cors';
import 'dotenv/config'; // Importa e configura o dotenv
import prisma from './prisma';

import authRoutes from './routes/authRoutes';
import userRoutes from './routes/userRoutes';
import inspectionRoutes from './routes/inspectionRoutes';
import photoRoutes from './routes/photoRoutes';
import syncRoutes from './routes/syncRoutes';
import publicRoutes from './routes/publicRoutes';
import { errorHandler } from './middlewares/errorHandler';

const app = express();

// Configuração do CORS - LIBERADO PARA TODAS AS ORIGENS
const corsOptions = {
  origin: '*', // ✅ Aceita qualquer origem
  credentials: false,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS', 'PATCH'],
  allowedHeaders: [
    'Origin',
    'X-Requested-With',
    'Content-Type',
    'Accept',
    'Authorization',
    'X-Client-Type',
    'Cache-Control',
    'Pragma',
    'If-Modified-Since',
    'If-None-Match',
    'ETag',
    'Last-Modified'
  ],
  exposedHeaders: ['Content-Length', 'X-Requested-With'],
  maxAge: 86400 // Cache preflight por 24 horas
};

// Middlewares
app.use(cors(corsOptions));
app.use(express.json({ limit: '10mb' })); // Aumentar limite para upload de fotos
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Test Route (ANTES das rotas)
app.get('/', (req: Request, res: Response) => {
  res.send('API is running!');
});

// Middleware de log para debug do CORS
app.use((req: Request, res: Response, next: NextFunction) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.path}`);
  console.log('Origin:', req.headers.origin);
  console.log('User-Agent:', req.headers['user-agent']);
  console.log('X-Client-Type:', req.headers['x-client-type']);
  next();
});

// Routes públicas (sem autenticação)
app.use('/public', publicRoutes);

// Routes protegidas (com autenticação)
app.use('/auth', authRoutes);
app.use('/users', userRoutes);
app.use('/photos', photoRoutes);
app.use('/inspections', inspectionRoutes);
app.use('/sync', syncRoutes);

// Error handling middleware
app.use(errorHandler);

// Export PrismaClient for use in services
export { prisma };
export default app; // Exportando a instância do app 