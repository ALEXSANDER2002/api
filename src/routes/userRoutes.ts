import { Router } from 'express';
import { userController } from '../controllers/userController';
import { authMiddleware } from '../middlewares/authMiddleware';
import { authorize } from '../middlewares/authorizationMiddleware';

const router = Router();

router.post('/', userController.createUser); // Public for user creation
router.get('/', authMiddleware, authorize(['ADMIN']), userController.getAllUsers);
router.get('/:id', authMiddleware, authorize(['ADMIN']), userController.getUserById);
router.put('/:id', authMiddleware, authorize(['ADMIN']), userController.updateUser);
router.delete('/:id', authMiddleware, authorize(['ADMIN']), userController.deleteUser);

export default router; 