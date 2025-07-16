import { Request, Response } from 'express';
import { userService } from '../services/userService';
import { ZodError } from 'zod';
import { createUserSchema, updateUserSchema } from '../utils/validationSchemas';

export const userController = {
  /**
   * @swagger
   * /users: 
   *   post:
   *     summary: Cria um novo usuário
   *     tags: [Users]
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             $ref: '#/components/schemas/UserInput'
   *     responses:
   *       201:
   *         description: Usuário criado com sucesso.
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/User'
   *       400:
   *         description: Dados de entrada inválidos.
   *       500:
   *         description: Erro interno do servidor.
   */
  createUser: async (req: Request, res: Response) => {
    try {
      const userData = createUserSchema.parse(req.body);
      const newUser = await userService.createUser(userData);
      res.status(201).json(newUser);
    } catch (error) {
      if (error instanceof ZodError) {
        return res.status(400).json({ message: 'Validation error', errors: error.issues });
      }
      if (error instanceof Error && error.message.includes('User with this email already exists')) {
        return res.status(409).json({ message: 'User with this email already exists' });
      }
      console.error('Error creating user:', error);
      res.status(500).json({ message: 'Internal server error' });
    }
  },

  /**
   * @swagger
   * /users:
   *   get:
   *     summary: Lista todos os usuários
   *     tags: [Users]
   *     security:
   *       - bearerAuth: []
   *     responses:
   *       200:
   *         description: Lista de usuários.
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
  getAllUsers: async (req: Request, res: Response) => {
    try {
      const users = await userService.getAllUsers();
      res.status(200).json(users);
    } catch (error) {
      console.error('Error fetching users:', error);
      res.status(500).json({ message: 'Internal server error' });
    }
  },

  /**
   * @swagger
   * /users/{id}:
   *   get:
   *     summary: Busca um usuário pelo ID
   *     tags: [Users]
   *     security:
   *       - bearerAuth: []
   *     parameters:
   *       - in: path
   *         name: id
   *         schema:
   *           type: integer
   *         required: true
   *         description: ID do usuário.
   *     responses:
   *       200:
   *         description: Dados do usuário.
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/User'
   *       404:
   *         description: Usuário não encontrado.
   *       401:
   *         description: Não autorizado.
   *       500:
   *         description: Erro interno do servidor.
   */
  getUserById: async (req: Request, res: Response) => {
    try {
      const { id } = req.params;
      const user = await userService.getUserById(Number(id));
      if (!user) {
        return res.status(404).json({ message: 'User not found' });
      }
      res.status(200).json(user);
    } catch (error) {
      console.error('Error fetching user by ID:', error);
      res.status(500).json({ message: 'Internal server error' });
    }
  },

  /**
   * @swagger
   * /users/{id}:
   *   put:
   *     summary: Atualiza um usuário existente
   *     tags: [Users]
   *     security:
   *       - bearerAuth: []
   *     parameters:
   *       - in: path
   *         name: id
   *         schema:
   *           type: integer
   *         required: true
   *         description: ID do usuário a ser atualizado.
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             $ref: '#/components/schemas/UserUpdateInput'
   *     responses:
   *       200:
   *         description: Usuário atualizado com sucesso.
   *         content:
   *           application/json:
   *             schema:
   *               $ref: '#/components/schemas/User'
   *       400:
   *         description: Dados de entrada inválidos.
   *       404:
   *         description: Usuário não encontrado.
   *       401:
   *         description: Não autorizado.
   *       500:
   *         description: Erro interno do servidor.
   */
  updateUser: async (req: Request, res: Response) => {
    try {
      const { id } = req.params;
      const userData = updateUserSchema.parse(req.body);
      const updatedUser = await userService.updateUser(Number(id), userData);
      res.status(200).json(updatedUser);
    } catch (error) {
      if (error instanceof ZodError) {
        return res.status(400).json({ message: 'Validation error', errors: error.issues });
      }
      console.error('Error updating user:', error);
      res.status(500).json({ message: 'Internal server error' });
    }
  },

  /**
   * @swagger
   * /users/{id}:
   *   delete:
   *     summary: Deleta um usuário
   *     tags: [Users]
   *     security:
   *       - bearerAuth: []
   *     parameters:
   *       - in: path
   *         name: id
   *         schema:
   *           type: integer
   *         required: true
   *         description: ID do usuário a ser deletado.
   *     responses:
   *       200:
   *         description: Usuário deletado com sucesso.
   *         content:
   *           application/json:
   *             schema:
   *               type: object
   *               properties:
   *                 message:
   *                   type: string
   *                   example: Usuário deletado com sucesso
   *       404:
   *         description: Usuário não encontrado.
   *       401:
   *         description: Não autorizado.
   *       500:
   *         description: Erro interno do servidor.
   */
  deleteUser: async (req: Request, res: Response) => {
    try {
      const { id } = req.params;
      await userService.deleteUser(Number(id));
      res.status(200).json({ message: 'User deleted successfully' });
    } catch (error) {
      if (error instanceof Error && error.message.includes('Record to delete does not exist')) {
        return res.status(404).json({ message: 'User not found' });
      }
      console.error('Error deleting user:', error);
      res.status(500).json({ message: 'Internal server error' });
    }
  },
}; 