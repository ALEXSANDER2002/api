"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.inspectionController = void 0;
const inspectionService_1 = require("../services/inspectionService");
const zod_1 = require("zod");
const validationSchemas_1 = require("../utils/validationSchemas");
exports.inspectionController = {
    /**
     * @swagger
     * /public/inspections:
     *   get:
     *     summary: Lista todas as inspeções (rota pública - sem autenticação)
     *     tags: [Inspections]
     *     security: []
     *     responses:
     *       200:
     *         description: Lista de inspeções.
     *         content:
     *           application/json:
     *             schema:
     *               type: array
     *               items:
     *                 $ref: '#/components/schemas/Inspection'
     *       500:
     *         description: Erro interno do servidor.
     */
    getAllInspectionsPublic: async (req, res) => {
        try {
            const inspections = await inspectionService_1.inspectionService.getAllInspections();
            res.status(200).json(inspections);
        }
        catch (error) {
            console.error('Error fetching inspections:', error);
            res.status(500).json({ message: 'Internal server error' });
        }
    },
    /**
     * @swagger
     * /inspections:
     *   post:
     *     summary: Cria uma nova inspeção
     *     tags: [Inspections]
     *     security:
     *       - bearerAuth: []
     *     requestBody:
     *       required: true
     *       content:
     *         application/json:
     *           schema:
     *             $ref: '#/components/schemas/InspectionInput'
     *     responses:
     *       201:
     *         description: Inspeção criada com sucesso.
     *         content:
     *           application/json:
     *             schema:
     *               $ref: '#/components/schemas/Inspection'
     *       400:
     *         description: Dados de entrada inválidos.
     *       401:
     *         description: Não autorizado.
     *       500:
     *         description: Erro interno do servidor.
     */
    createInspection: async (req, res) => {
        try {
            const inspectionData = validationSchemas_1.createInspectionSchema.parse(req.body);
            const newInspection = await inspectionService_1.inspectionService.createInspection(inspectionData);
            res.status(201).json(newInspection);
        }
        catch (error) {
            if (error instanceof zod_1.ZodError) {
                return res.status(400).json({ message: 'Validation error', errors: error.issues });
            }
            console.error('Error creating inspection:', error);
            res.status(500).json({ message: 'Internal server error' });
        }
    },
    /**
     * @swagger
     * /inspections:
     *   get:
     *     summary: Lista todas as inspeções
     *     tags: [Inspections]
     *     security:
     *       - bearerAuth: []
     *     responses:
     *       200:
     *         description: Lista de inspeções.
     *         content:
     *           application/json:
     *             schema:
     *               type: array
     *               items:
     *                 $ref: '#/components/schemas/Inspection'
     *       401:
     *         description: Não autorizado.
     *       500:
     *         description: Erro interno do servidor.
     */
    getAllInspections: async (req, res) => {
        try {
            const inspections = await inspectionService_1.inspectionService.getAllInspections();
            res.status(200).json(inspections);
        }
        catch (error) {
            console.error('Error fetching inspections:', error);
            res.status(500).json({ message: 'Internal server error' });
        }
    },
    /**
     * @swagger
     * /inspections/{id}:
     *   get:
     *     summary: Busca uma inspeção pelo ID
     *     tags: [Inspections]
     *     security:
     *       - bearerAuth: []
     *     parameters:
     *       - in: path
     *         name: id
     *         schema:
     *           type: integer
     *         required: true
     *         description: ID da inspeção.
     *     responses:
     *       200:
     *         description: Dados da inspeção.
     *         content:
     *           application/json:
     *             schema:
     *               $ref: '#/components/schemas/Inspection'
     *       404:
     *         description: Inspeção não encontrada.
     *       401:
     *         description: Não autorizado.
     *       500:
     *         description: Erro interno do servidor.
     */
    getInspectionById: async (req, res) => {
        try {
            const { id } = req.params;
            const inspection = await inspectionService_1.inspectionService.getInspectionById(Number(id));
            if (!inspection) {
                return res.status(404).json({ message: 'Inspection not found' });
            }
            res.status(200).json(inspection);
        }
        catch (error) {
            console.error('Error fetching inspection by ID:', error);
            res.status(500).json({ message: 'Internal server error' });
        }
    },
    /**
     * @swagger
     * /inspections/{id}:
     *   put:
     *     summary: Atualiza uma inspeção existente
     *     tags: [Inspections]
     *     security:
     *       - bearerAuth: []
     *     parameters:
     *       - in: path
     *         name: id
     *         schema:
     *           type: integer
     *         required: true
     *         description: ID da inspeção a ser atualizada.
     *     requestBody:
     *       required: true
     *       content:
     *         application/json:
     *           schema:
     *             $ref: '#/components/schemas/InspectionUpdateInput'
     *     responses:
     *       200:
     *         description: Inspeção atualizada com sucesso.
     *         content:
     *           application/json:
     *             schema:
     *               $ref: '#/components/schemas/Inspection'
     *       400:
     *         description: Dados de entrada inválidos.
     *       404:
     *         description: Inspeção não encontrada.
     *       401:
     *         description: Não autorizado.
     *       500:
     *         description: Erro interno do servidor.
     */
    updateInspection: async (req, res) => {
        try {
            const { id } = req.params;
            const inspectionData = validationSchemas_1.updateInspectionSchema.parse(req.body);
            const updatedInspection = await inspectionService_1.inspectionService.updateInspection(Number(id), inspectionData);
            res.status(200).json(updatedInspection);
        }
        catch (error) {
            if (error instanceof zod_1.ZodError) {
                return res.status(400).json({ message: 'Validation error', errors: error.issues });
            }
            console.error('Error updating inspection:', error);
            res.status(500).json({ message: 'Internal server error' });
        }
    },
    /**
     * @swagger
     * /inspections/{id}:
     *   delete:
     *     summary: Deleta uma inspeção
     *     tags: [Inspections]
     *     security:
     *       - bearerAuth: []
     *     parameters:
     *       - in: path
     *         name: id
     *         schema:
     *           type: integer
     *         required: true
     *         description: ID da inspeção a ser deletada.
     *     responses:
     *       200:
     *         description: Inspeção deletada com sucesso.
     *         content:
     *           application/json:
     *             schema:
     *               type: object
     *               properties:
     *                 message:
     *                   type: string
     *                   example: Inspeção deletada com sucesso
     *       404:
     *         description: Inspeção não encontrada.
     *       401:
     *         description: Não autorizado.
     *       500:
     *         description: Erro interno do servidor.
     */
    deleteInspection: async (req, res) => {
        try {
            const { id } = req.params;
            await inspectionService_1.inspectionService.deleteInspection(Number(id));
            res.status(200).json({ message: 'Inspection deleted successfully' });
        }
        catch (error) {
            if (error instanceof Error && error.message.includes('Record to delete does not exist')) {
                return res.status(404).json({ message: 'Inspection not found' });
            }
            console.error('Error deleting inspection:', error);
            res.status(500).json({ message: 'Internal server error' });
        }
    },
};
