import { Request, Response } from 'express';
import { authService } from '../services/authService';
import { ZodError } from 'zod';
import { registerSchema, loginSchema } from '../utils/validationSchemas';

export const authController = {
  /**
   * @swagger
   * /auth/register:
   *   post:
   *     summary: Registra um novo usuário
   *     tags: [Auth]
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             $ref: '#/components/schemas/RegisterInput'
   *     responses:
   *       201:
   *         description: Usuário registrado com sucesso e token JWT.
   *         content:
   *           application/json:
   *             schema:
   *               type: object
   *               properties:
   *                 user:
   *                   $ref: '#/components/schemas/User'
   *                 token:
   *                   type: string
   *       400:
   *         description: Dados de entrada inválidos.
   *       409:
   *         description: Usuário com este email já existe.
   *       500:
   *         description: Erro interno do servidor.
   */
  register: async (req: Request, res: Response) => {
    try {
      const { email, password, name, role } = registerSchema.parse(req.body);
      const { user, token } = await authService.register(email, password, name, role);
      res.status(201).json({ user, token });
    } catch (error) {
      if (error instanceof ZodError) {
        return res.status(400).json({ message: 'Validation error', errors: error.issues });
      }
      if (error instanceof Error && error.message.includes('User with this email already exists')) {
        return res.status(409).json({ message: error.message });
      }
      console.error('Error during registration:', error);
      res.status(500).json({ message: 'Internal server error' });
    }
  },

  /**
   * @swagger
   * /auth/login:
   *   post:
   *     summary: Autentica um usuário e retorna um token JWT
   *     tags: [Auth]
   *     requestBody:
   *       required: true
   *       content:
   *         application/json:
   *           schema:
   *             $ref: '#/components/schemas/LoginInput'
   *     responses:
   *       200:
   *         description: Login bem-sucedido e token JWT.
   *         content:
   *           application/json:
   *             schema:
   *               type: object
   *               properties:
   *                 user:
   *                   $ref: '#/components/schemas/User'
   *                 token:
   *                   type: string
   *       400:
   *         description: Dados de entrada inválidos.
   *       401:
   *         description: Credenciais inválidas.
   *       500:
   *         description: Erro interno do servidor.
   */
  login: async (req: Request, res: Response) => {
    try {
      const { email, password } = loginSchema.parse(req.body);
      const { user, token } = await authService.login(email, password);
      res.status(200).json({ user, token });
    } catch (error) {
      if (error instanceof ZodError) {
        return res.status(400).json({ message: 'Validation error', errors: error.issues });
      }
      if (error instanceof Error && error.message.includes('Invalid credentials')) {
        return res.status(401).json({ message: error.message });
      }
      console.error('Error during login:', error);
      res.status(500).json({ message: 'Internal server error' });
    }
  },
}; 