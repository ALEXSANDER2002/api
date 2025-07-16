"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const userController_1 = require("../controllers/userController");
const authMiddleware_1 = require("../middlewares/authMiddleware");
const authorizationMiddleware_1 = require("../middlewares/authorizationMiddleware");
const router = (0, express_1.Router)();
router.post('/', userController_1.userController.createUser); // Public for user creation
router.get('/', authMiddleware_1.authMiddleware, (0, authorizationMiddleware_1.authorize)(['ADMIN']), userController_1.userController.getAllUsers);
router.get('/:id', authMiddleware_1.authMiddleware, (0, authorizationMiddleware_1.authorize)(['ADMIN']), userController_1.userController.getUserById);
router.put('/:id', authMiddleware_1.authMiddleware, (0, authorizationMiddleware_1.authorize)(['ADMIN']), userController_1.userController.updateUser);
router.delete('/:id', authMiddleware_1.authMiddleware, (0, authorizationMiddleware_1.authorize)(['ADMIN']), userController_1.userController.deleteUser);
exports.default = router;
