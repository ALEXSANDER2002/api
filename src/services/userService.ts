import * as bcrypt from 'bcryptjs';
import prisma from '../prisma';

// Removido: const prisma = new PrismaClient();

export const userService = {
  /**
   * Creates a new user.
   * @param data User data including email, name (optional), password, and role (optional).
   * @returns The created user object.
   */
  createUser: async (data: { email: string; name?: string; password?: string; role?: 'USER' | 'ADMIN' }) => {
    const { email, name, password, role } = data;
    // Verifica se já existe usuário com o mesmo e-mail
    const existingUser = await prisma.user.findUnique({ where: { email } });
    if (existingUser) {
      throw new Error('User with this email already exists');
    }
    let hashedPassword;
    if (password) {
      hashedPassword = await bcrypt.hash(password, 10);
    }
    return prisma.user.create({
      data: { email, name, password: hashedPassword, role },
    });
  },

  /**
   * Retrieves all users.
   * @returns An array of user objects.
   */
  getAllUsers: async () => {
    return prisma.user.findMany({
      select: { id: true, email: true, name: true, createdAt: true, role: true }, // Include role
    });
  },

  /**
   * Retrieves a user by their ID.
   * @param id The ID of the user to retrieve.
   * @returns The user object, or null if not found.
   */
  getUserById: async (id: number) => {
    return prisma.user.findUnique({
      where: { id },
      select: { id: true, email: true, name: true, createdAt: true, role: true }, // Include role
    });
  },

  /**
   * Retrieves a user by their email.
   * @param email The email of the user to retrieve.
   * @returns The user object, or null if not found.
   */
  getUserByEmail: async (email: string) => {
    return prisma.user.findUnique({
      where: { email },
    });
  },

  /**
   * Updates an existing user.
   * @param id The ID of the user to update.
   * @param data New user data.
   * @returns The updated user object.
   */
  updateUser: async (id: number, data: { email?: string; name?: string; password?: string; role?: 'USER' | 'ADMIN' }) => {
    if (data.password) {
      data.password = await bcrypt.hash(data.password, 10);
    }
    return prisma.user.update({
      where: { id },
      data,
      select: { id: true, email: true, name: true, createdAt: true, role: true }, // Include role
    });
  },

  /**
   * Deletes a user by their ID.
   * @param id The ID of the user to delete.
   * @returns The deleted user object.
   */
  deleteUser: async (id: number) => {
    return prisma.user.delete({
      where: { id },
      select: { id: true, email: true, name: true, createdAt: true, role: true }, // Include role
    });
  },
}; 