import { Router } from 'express';
import { photoController } from '../controllers/photoController';

const router = Router();

// TODAS AS ROTAS LIBERADAS - SEM AUTENTICAÇÃO
router.post('/inspections/:inspectionId/photos', photoController.addPhoto);
router.get('/inspections/:inspectionId/photos', photoController.getPhotosByInspectionId);
router.delete('/photos/:id', photoController.deletePhoto);

export default router; 