import express from 'express';
import cors from 'cors';
import 'dotenv/config'; // Importa e configura o dotenv
import prisma from './prisma';

import authRoutes from './routes/authRoutes';
import userRoutes from './routes/userRoutes';
import inspectionRoutes from './routes/inspectionRoutes';
import photoRoutes from './routes/photoRoutes';
import syncRoutes from './routes/syncRoutes';
import { errorHandler } from './middlewares/errorHandler';

const app = express();

// Middlewares
app.use(cors());
app.use(express.json());

// Routes
app.use('/auth', authRoutes);
app.use('/users', userRoutes);
app.use('/photos', photoRoutes);
app.use('/inspections', inspectionRoutes);
app.use('/sync', syncRoutes);

// Error handling middleware
app.use(errorHandler);

// Health Check endpoint
app.get('/health', async (req, res) => {
  try {
    // Testa conexão com banco
    await prisma.$queryRaw`SELECT 1`;
    res.json({
      status: 'OK',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      database: 'connected',
      version: '1.0.0'
    });
  } catch (error) {
    res.status(500).json({
      status: 'ERROR',
      timestamp: new Date().toISOString(),
      database: 'disconnected',
      error: 'Database connection failed'
    });
  }
});

// Test Route
app.get('/', (req, res) => {
  res.send('API is running!');
});

// Export PrismaClient for use in services
export { prisma };
export default app; // Exportando a instância do app 