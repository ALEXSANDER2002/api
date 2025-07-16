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

// Test Route
app.get('/', (req, res) => {
  res.send('API is running!');
});

// Export PrismaClient for use in services
export { prisma };
export default app; // Exportando a instância do app 