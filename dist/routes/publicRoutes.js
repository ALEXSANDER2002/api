"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const inspectionController_1 = require("../controllers/inspectionController");
const router = (0, express_1.Router)();
// Rotas públicas (sem autenticação)
router.get('/inspections', inspectionController_1.inspectionController.getAllInspectionsPublic); // Lista inspeções públicas
exports.default = router;
