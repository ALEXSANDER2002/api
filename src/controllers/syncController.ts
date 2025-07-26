import { Request, Response } from 'express';
import { syncService } from '../services/syncService';
import { ZodError } from 'zod';
import { syncPayloadSchema } from '../utils/validationSchemas';
import prisma from '../prisma';

export const syncController = {
  /**
   * @swagger
   * /sync:
   *   post:
   *     summary: Sincroniza dados do aplicativo móvel para o backend
   *     tags: [Sync]
   *     security: []  // Removido - endpoint público para mobile
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
  syncData: async (req: Request, res: Response) => {
    try {
      const syncPayload = syncPayloadSchema.parse(req.body);
      const result = await syncService.syncData(syncPayload);
      res.status(200).json(result);
    } catch (error) {
      if (error instanceof ZodError) {
        return res.status(400).json({ message: 'Validation error', errors: error.issues });
      }
      console.error('Error during synchronization:', error);
      res.status(500).json({ message: 'Internal server error' });
    }
  },

  /**
   * @swagger
   * /sync/users:
   *   get:
   *     summary: Sincroniza usuários do banco de dados para o backend
   *     tags: [Sync]
   *     security: []  // Removido - endpoint público para mobile
   *     responses:
   *       200:
   *         description: Usuários sincronizados com sucesso.
   *         content:
   *           application/json:
   *             schema:
   *               type: array
   *               items:
   *                 $ref: '#/components/schemas/User'
   *       401:
   *         description: Não autorizado.
   *       500:
   *         description: Erro interno do servidor.
   */
  syncUsers: async (req: Request, res: Response) => {
    try {
      const users = await prisma.user.findMany();
      res.json({ syncedUsers: users, syncedInspections: [], syncedPhotos: [], conflicts: [] });
    } catch (error) {
      console.error('Erro ao sincronizar usuários:', error);
      res.status(500).json({ error: 'Erro ao sincronizar usuários' });
    }
  },
}; 