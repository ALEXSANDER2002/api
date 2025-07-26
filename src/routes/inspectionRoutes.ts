import { Router } from 'express';
import { inspectionController } from '../controllers/inspectionController';
import { authMiddleware } from '../middlewares/authMiddleware';
import { authorize } from '../middlewares/authorizationMiddleware';

const router = Router();

// Rotas públicas (sem autenticação)
router.get('/public', inspectionController.getAllInspectionsPublic); // Rota pública para listar inspeções

// Rotas protegidas (com autenticação)
router.post('/', authMiddleware, authorize(['USER', 'ADMIN']), inspectionController.createInspection);
router.get('/', authMiddleware, authorize(['USER', 'ADMIN']), inspectionController.getAllInspections);
router.get('/:id', authMiddleware, authorize(['USER', 'ADMIN']), inspectionController.getInspectionById);
router.put('/:id', authMiddleware, authorize(['USER', 'ADMIN']), inspectionController.updateInspection);
router.delete('/:id', authMiddleware, authorize(['USER', 'ADMIN']), inspectionController.deleteInspection);

export default router; 