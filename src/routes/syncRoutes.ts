import { Router } from 'express';
import { syncController } from '../controllers/syncController';
import { mobileAuthMiddleware } from '../middlewares/mobileAuthMiddleware';

const router = Router();

// Middleware inteligente: público para mobile, autenticado para web
router.post('/', mobileAuthMiddleware, syncController.syncData);

export default router; 