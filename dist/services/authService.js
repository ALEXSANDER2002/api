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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.authService = void 0;
const prisma_1 = __importDefault(require("../prisma"));
const bcrypt = __importStar(require("bcryptjs"));
const jwt = __importStar(require("jsonwebtoken"));
const JWT_SECRET = process.env.JWT_SECRET || 'your_jwt_secret_here'; // Fallback for safety
exports.authService = {
    /**
     * Registers a new user.
     * @param email User's email.
     * @param password User's password.
     * @param name User's name (optional).
     * @param role User's role (optional, defaults to USER).
     * @returns The newly created user (excluding password) and a JWT token.
     * @throws Error if user with email already exists.
     */
    register: async (email, password, name, role) => {
        const existingUser = await prisma_1.default.user.findUnique({ where: { email } });
        if (existingUser) {
            throw new Error('User with this email already exists');
        }
        const hashedPassword = await bcrypt.hash(password, 10);
        const newUser = await prisma_1.default.user.create({
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
    login: async (email, password) => {
        const user = await prisma_1.default.user.findUnique({ where: { email } });
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
    verifyToken: (token) => {
        try {
            return jwt.verify(token, JWT_SECRET); // Include role
        }
        catch (error) {
            throw new Error('Invalid or expired token');
        }
    },
};
