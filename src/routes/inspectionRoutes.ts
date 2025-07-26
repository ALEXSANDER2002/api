import { Router } from 'express';
import { inspectionController } from '../controllers/inspectionController';

const router = Router();

// TODAS AS ROTAS LIBERADAS - SEM AUTENTICAÇÃO
router.post('/', inspectionController.createInspection);
router.get('/', inspectionController.getAllInspections);
router.get('/public', inspectionController.getAllInspectionsPublic);
router.get('/:id', inspectionController.getInspectionById);
router.put('/:id', inspectionController.updateInspection);
router.delete('/:id', inspectionController.deleteInspection);

export default router; 