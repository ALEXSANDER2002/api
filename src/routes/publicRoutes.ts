import { Router } from 'express';
import { inspectionController } from '../controllers/inspectionController';

const router = Router();

// Rotas públicas (sem autenticação)
router.get('/inspections', inspectionController.getAllInspectionsPublic); // Lista inspeções públicas

export default router; 