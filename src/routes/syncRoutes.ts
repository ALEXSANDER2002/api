import { Router } from 'express';
import { syncController } from '../controllers/syncController';

const router = Router();

router.post('/', syncController.syncData);

export default router; 