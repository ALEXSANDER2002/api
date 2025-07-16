import prisma from '../prisma';
import * as bcrypt from 'bcryptjs';
import * as jwt from 'jsonwebtoken';
import { User } from '@prisma/client';

const JWT_SECRET = process.env.JWT_SECRET || 'your_jwt_secret_here'; // Fallback for safety

export const authService = {
  /**
   * Registers a new user.
   * @param email User's email.
   * @param password User's password.
   * @param name User's name (optional).
   * @param role User's role (optional, defaults to USER).
   * @returns The newly created user (excluding password) and a JWT token.
   * @throws Error if user with email already exists.
   */
  register: async (email: string, password: string, name?: string, role?: 'USER' | 'ADMIN') => {
    const existingUser = await prisma.user.findUnique({ where: { email } });
    if (existingUser) {
      throw new Error('User with this email already exists');
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const newUser = await prisma.user.create({
      data: { email, name, password: hashedPassword, role: role || 'USER' }, // Set default role
    });

    const token = jwt.sign({ userId: newUser.id, email: newUser.email, role: newUser.role }, JWT_SECRET, { expiresIn: '1h' });

    // Exclude password from the returned user object
    const { password: _, ...userWithoutPassword } = newUser;
    return { user: userWithoutPassword, token };
  },

  /**
   * Authenticates a user and generates a JWT token.
   * @param email User's email.
   * @param password User's password.
   * @returns The authenticated user (excluding password) and a JWT token.
   * @throws Error if invalid credentials.
   */
  login: async (email: string, password: string) => {
    const user = await prisma.user.findUnique({ where: { email } });
    if (!user || !user.password) {
      throw new Error('Invalid credentials');
    }

    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      throw new Error('Invalid credentials');
    }

    const token = jwt.sign({ userId: user.id, email: user.email, role: user.role }, JWT_SECRET, { expiresIn: '1h' });

    // Exclude password from the returned user object
    const { password: _, ...userWithoutPassword } = user;
    return { user: userWithoutPassword, token };
  },

  /**
   * Verifies a JWT token.
   * @param token The JWT token to verify.
   * @returns The decoded token payload if valid.
   * @throws Error if the token is invalid or expired.
   */
  verifyToken: (token: string) => {
    try {
      return jwt.verify(token, JWT_SECRET) as { userId: number; email: string; role: 'USER' | 'ADMIN' }; // Include role
    } catch (error) {
      throw new Error('Invalid or expired token');
    }
  },
}; 