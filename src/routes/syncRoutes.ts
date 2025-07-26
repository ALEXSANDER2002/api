import { Router } from 'express';
import { syncController } from '../controllers/syncController';

const router = Router();

// ENDPOINT SYNC TOTALMENTE LIBERADO - SEM AUTENTICAÇÃO
router.post('/', syncController.syncData);

export default router; 