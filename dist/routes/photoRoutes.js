"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const photoController_1 = require("../controllers/photoController");
const authMiddleware_1 = require("../middlewares/authMiddleware");
const authorizationMiddleware_1 = require("../middlewares/authorizationMiddleware");
const router = (0, express_1.Router)();
// Rotas para fotos relacionadas a uma inspeção específica
router.post('/inspections/:inspectionId/photos', authMiddleware_1.authMiddleware, (0, authorizationMiddleware_1.authorize)(['USER', 'ADMIN']), photoController_1.photoController.addPhoto);
router.get('/inspections/:inspectionId/photos', authMiddleware_1.authMiddleware, (0, authorizationMiddleware_1.authorize)(['USER', 'ADMIN']), photoController_1.photoController.getPhotosByInspectionId);
// Rota para deletar uma foto (diretamente pelo ID da foto)
router.delete('/photos/:id', authMiddleware_1.authMiddleware, (0, authorizationMiddleware_1.authorize)(['USER', 'ADMIN']), photoController_1.photoController.deletePhoto);
exports.default = router;
