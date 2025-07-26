"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const userController_1 = require("../controllers/userController");
const router = (0, express_1.Router)();
// TODAS AS ROTAS LIBERADAS - SEM AUTENTICAÇÃO
router.post('/', userController_1.userController.createUser);
router.get('/', userController_1.userController.getAllUsers);
router.get('/:id', userController_1.userController.getUserById);
router.put('/:id', userController_1.userController.updateUser);
router.delete('/:id', userController_1.userController.deleteUser);
exports.default = router;
