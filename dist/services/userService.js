"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.userService = void 0;
const bcrypt = __importStar(require("bcryptjs"));
const app_1 = require("../app"); // Importe a instância prisma centralizada
// Removido: const prisma = new PrismaClient();
exports.userService = {
    /**
     * Creates a new user.
     * @param data User data including email, name (optional), password, and role (optional).
     * @returns The created user object.
     */
    createUser: async (data) => {
        const { email, name, password, role } = data;
        let hashedPassword;
        if (password) {
            hashedPassword = await bcrypt.hash(password, 10);
        }
        return app_1.prisma.user.create({
            data: { email, name, password: hashedPassword, role },
        });
    },
    /**
     * Retrieves all users.
     * @returns An array of user objects.
     */
    getAllUsers: async () => {
        return app_1.prisma.user.findMany({
            select: { id: true, email: true, name: true, createdAt: true, role: true }, // Include role
        });
    },
    /**
     * Retrieves a user by their ID.
     * @param id The ID of the user to retrieve.
     * @returns The user object, or null if not found.
     */
    getUserById: async (id) => {
        return app_1.prisma.user.findUnique({
            where: { id },
            select: { id: true, email: true, name: true, createdAt: true, role: true }, // Include role
        });
    },
    /**
     * Retrieves a user by their email.
     * @param email The email of the user to retrieve.
     * @returns The user object, or null if not found.
     */
    getUserByEmail: async (email) => {
        return app_1.prisma.user.findUnique({
            where: { email },
        });
    },
    /**
     * Updates an existing user.
     * @param id The ID of the user to update.
     * @param data New user data.
     * @returns The updated user object.
     */
    updateUser: async (id, data) => {
        if (data.password) {
            data.password = await bcrypt.hash(data.password, 10);
        }
        return app_1.prisma.user.update({
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
    deleteUser: async (id) => {
        return app_1.prisma.user.delete({
            where: { id },
            select: { id: true, email: true, name: true, createdAt: true, role: true }, // Include role
        });
    },
};
