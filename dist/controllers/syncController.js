"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.syncController = void 0;
const syncService_1 = require("../services/syncService");
const zod_1 = require("zod");
const validationSchemas_1 = require("../utils/validationSchemas");
exports.syncController = {
    /**
     * @swagger
     * /sync:
     *   post:
     *     summary: Sincroniza dados do aplicativo móvel para o backend
     *     tags: [Sync]
     *     security:
     *       - bearerAuth: []
     *     requestBody:
     *       required: true
     *       content:
     *         application/json:
     *           schema:
     *             $ref: '#/components/schemas/SyncPayload'
     *     responses:
     *       200:
     *         description: Dados sincronizados com sucesso.
     *         content:
     *           application/json:
     *             schema:
     *               $ref: '#/components/schemas/SyncResult'
     *       400:
     *         description: Dados de entrada inválidos.
     *       401:
     *         description: Não autorizado.
     *       500:
     *         description: Erro interno do servidor.
     */
    syncData: async (req, res) => {
        try {
            const syncPayload = validationSchemas_1.syncPayloadSchema.parse(req.body);
            const result = await syncService_1.syncService.syncData(syncPayload);
            res.status(200).json(result);
        }
        catch (error) {
            if (error instanceof zod_1.ZodError) {
                return res.status(400).json({ message: 'Validation error', errors: error.issues });
            }
            console.error('Error during synchronization:', error);
            res.status(500).json({ message: 'Internal server error' });
        }
    },
};
