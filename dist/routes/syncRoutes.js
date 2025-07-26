"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const syncController_1 = require("../controllers/syncController");
const router = (0, express_1.Router)();
// ENDPOINT SYNC TOTALMENTE LIBERADO - SEM AUTENTICAÇÃO
router.post('/', syncController_1.syncController.syncData);
exports.default = router;
