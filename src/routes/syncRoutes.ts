import { Router } from 'express';
import { syncController } from '../controllers/syncController';
import { authMiddleware } from '../middlewares/authMiddleware';
import { authorize } from '../middlewares/authorizationMiddleware';

const router = Router();

router.post('/', authMiddleware, authorize(['ADMIN']), syncController.syncData);

export default router; 