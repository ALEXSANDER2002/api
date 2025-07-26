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

// Configuração do CORS - CORRIGIDA para evitar múltiplos valores
const corsOptions = {
  origin: function (origin: string | undefined, callback: (err: Error | null, allow?: boolean) => void) {
    // Lista de origens permitidas
    const allowedOrigins = [
      'http://localhost:3000',
      'http://localhost:3001', 
      'http://localhost:8080',
      'http://localhost:5173',
      'http://127.0.0.1:3000',
      'http://127.0.0.1:3001',
      'http://127.0.0.1:8080',
      'http://127.0.0.1:5173',
      'https://rondacheck.com.br',
      'https://www.rondacheck.com.br',
      // Para desenvolvimento mobile (React Native, Expo, etc.)
      'exp://localhost:19000',
      'exp://192.168.1.100:19000',
      'exp://10.0.2.2:19000',
      // Para apps mobile que fazem requisições diretas
      'capacitor://localhost',
      'ionic://localhost'
    ];

    // Permitir requisições sem origin (como apps mobile ou Postman)
    if (!origin) {
      return callback(null, true);
    }

    // Verificar se a origem está na lista de permitidas
    if (allowedOrigins.indexOf(origin) !== -1) {
      return callback(null, true);
    }

    // Para desenvolvimento, permitir todas as origens
    if (process.env.NODE_ENV === 'development') {
      return callback(null, true);
    }

    // Para produção, rejeitar origens não autorizadas
    callback(new Error('Not allowed by CORS'));
  },
  credentials: false, // Mudado para false para evitar problemas de CORS
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS', 'PATCH'],
  allowedHeaders: [
    'Origin',
    'X-Requested-With',
    'Content-Type',
    'Accept',
    'Authorization',
    'X-Client-Type',
    'Cache-Control',
    'Pragma'
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