"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const photoController_1 = require("../controllers/photoController");
const router = (0, express_1.Router)();
// TODAS AS ROTAS LIBERADAS - SEM AUTENTICAÇÃO
router.post('/inspections/:inspectionId/photos', photoController_1.photoController.addPhoto);
router.get('/inspections/:inspectionId/photos', photoController_1.photoController.getPhotosByInspectionId);
router.delete('/photos/:id', photoController_1.photoController.deletePhoto);
exports.default = router;
