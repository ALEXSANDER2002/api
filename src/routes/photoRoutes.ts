import { Router } from 'express';
import { photoController } from '../controllers/photoController';
import { authMiddleware } from '../middlewares/authMiddleware';
import { authorize } from '../middlewares/authorizationMiddleware';

const router = Router();

// Rotas para fotos relacionadas a uma inspeção específica
router.post('/inspections/:inspectionId/photos', authMiddleware, authorize(['USER', 'ADMIN']), photoController.addPhoto);
router.get('/inspections/:inspectionId/photos', authMiddleware, authorize(['USER', 'ADMIN']), photoController.getPhotosByInspectionId);

// Rota para deletar uma foto (diretamente pelo ID da foto)
router.delete('/photos/:id', authMiddleware, authorize(['USER', 'ADMIN']), photoController.deletePhoto);

export default router; 