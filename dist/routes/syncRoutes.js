"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const syncController_1 = require("../controllers/syncController");
const authMiddleware_1 = require("../middlewares/authMiddleware");
const authorizationMiddleware_1 = require("../middlewares/authorizationMiddleware");
const router = (0, express_1.Router)();
router.post('/', authMiddleware_1.authMiddleware, (0, authorizationMiddleware_1.authorize)(['ADMIN']), syncController_1.syncController.syncData);
exports.default = router;
