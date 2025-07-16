"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.photoController = void 0;
const photoService_1 = require("../services/photoService");
const zod_1 = require("zod");
const validationSchemas_1 = require("../utils/validationSchemas");
exports.photoController = {
    /**
     * @swagger
     * /inspections/{inspectionId}/photos:
     *   post:
     *     summary: Adiciona uma nova foto a uma inspeção
     *     tags: [Photos]
     *     security:
     *       - bearerAuth: []
     *     parameters:
     *       - in: path
     *         name: inspectionId
     *         schema:
     *           type: integer
     *         required: true
     *         description: ID da inspeção à qual a foto pertence.
     *     requestBody:
     *       required: true
     *       content:
     *         application/json:
     *           schema:
     *             $ref: '#/components/schemas/PhotoInput'
     *     responses:
     *       201:
     *         description: Foto adicionada com sucesso.
     *         content:
     *           application/json:
     *             schema:
     *               $ref: '#/components/schemas/Photo'
     *       400:
     *         description: Dados de entrada inválidos.
     *       401:
     *         description: Não autorizado.
     *       500:
     *         description: Erro interno do servidor.
     */
    addPhoto: async (req, res) => {
        try {
            const { inspectionId } = req.params;
            const photoData = validationSchemas_1.addPhotoSchema.parse(req.body);
            const newPhoto = await photoService_1.photoService.addPhoto(Number(inspectionId), photoData.url);
            res.status(201).json(newPhoto);
        }
        catch (error) {
            if (error instanceof zod_1.ZodError) {
                return res.status(400).json({ message: 'Validation error', errors: error.issues });
            }
            if (error instanceof Error && error.message.includes('Record to connect does not exist')) {
                return res.status(404).json({ message: 'Inspection not found' });
            }
            res.status(500).json({ message: 'Internal server error' });
        }
    },
    /**
     * @swagger
     * /inspections/{inspectionId}/photos:
     *   get:
     *     summary: Lista todas as fotos de uma inspeção específica
     *     tags: [Photos]
     *     security:
     *       - bearerAuth: []
     *     parameters:
     *       - in: path
     *         name: inspectionId
     *         schema:
     *           type: integer
     *         required: true
     *         description: ID da inspeção.
     *     responses:
     *       200:
     *         description: Lista de fotos.
     *         content:
     *           application/json:
     *             schema:
     *               type: array
     *               items:
     *                 $ref: '#/components/schemas/Photo'
     *       401:
     *         description: Não autorizado.
     *       404:
     *         description: Inspeção não encontrada.
     *       500:
     *         description: Erro interno do servidor.
     */
    getPhotosByInspectionId: async (req, res) => {
        try {
            const { inspectionId } = req.params;
            // Optionally, check if inspection exists before fetching photos
            const photos = await photoService_1.photoService.getPhotosByInspectionId(Number(inspectionId));
            res.status(200).json(photos);
        }
        catch (error) {
            res.status(500).json({ message: 'Internal server error' });
        }
    },
    /**
     * @swagger
     * /photos/{id}:
     *   delete:
     *     summary: Deleta uma foto
     *     tags: [Photos]
     *     security:
     *       - bearerAuth: []
     *     parameters:
     *       - in: path
     *         name: id
     *         schema:
     *           type: integer
     *         required: true
     *         description: ID da foto a ser deletada.
     *     responses:
     *       200:
     *         description: Foto deletada com sucesso.
     *         content:
     *           application/json:
     *             schema:
     *               type: object
     *               properties:
     *                 message:
     *                   type: string
     *                   example: Foto deletada com sucesso
     *       404:
     *         description: Foto não encontrada.
     *       401:
     *         description: Não autorizado.
     *       500:
     *         description: Erro interno do servidor.
     */
    deletePhoto: async (req, res) => {
        const { id } = req.params;
        try {
            const photo = await photoService_1.photoService.deletePhoto(Number(id));
            if (!photo) {
                return res.status(404).json({ error: 'Foto não encontrada' });
            }
            res.status(200).json({ message: 'Foto deletada com sucesso' });
        }
        catch (error) {
            res.status(500).json({ error: 'Erro ao deletar foto' });
        }
    },
};
