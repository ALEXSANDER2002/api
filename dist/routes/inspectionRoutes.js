"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const inspectionController_1 = require("../controllers/inspectionController");
const router = (0, express_1.Router)();
// TODAS AS ROTAS LIBERADAS - SEM AUTENTICAÇÃO
router.post('/', inspectionController_1.inspectionController.createInspection);
router.get('/', inspectionController_1.inspectionController.getAllInspections);
router.get('/public', inspectionController_1.inspectionController.getAllInspectionsPublic);
router.get('/:id', inspectionController_1.inspectionController.getInspectionById);
router.put('/:id', inspectionController_1.inspectionController.updateInspection);
router.delete('/:id', inspectionController_1.inspectionController.deleteInspection);
exports.default = router;
