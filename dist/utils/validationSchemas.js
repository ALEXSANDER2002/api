"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.syncPayloadSchema = exports.loginSchema = exports.registerSchema = exports.addPhotoSchema = exports.updateInspectionSchema = exports.createInspectionSchema = exports.updateUserSchema = exports.createUserSchema = void 0;
const zod_1 = require("zod");
exports.createUserSchema = zod_1.z.object({
    email: zod_1.z.string().email("Invalid email address"),
    name: zod_1.z.string().optional(),
    password: zod_1.z.string().min(6, "Password must be at least 6 characters long"),
});
exports.updateUserSchema = zod_1.z.object({
    email: zod_1.z.string().email("Invalid email address").optional(),
    name: zod_1.z.string().optional(),
    password: zod_1.z.string().min(6, "Password must be at least 6 characters long").optional(),
});
exports.createInspectionSchema = zod_1.z.object({
    title: zod_1.z.string().min(1, "Title is required"),
    description: zod_1.z.string().optional(),
    status: zod_1.z.enum(['pending', 'completed', 'synced'], { message: "Invalid status" }),
    userId: zod_1.z.number().int("User ID must be an integer"),
});
exports.updateInspectionSchema = zod_1.z.object({
    title: zod_1.z.string().min(1, "Title is required").optional(),
    description: zod_1.z.string().optional(),
    status: zod_1.z.enum(['pending', 'completed', 'synced'], { message: "Invalid status" }).optional(),
    userId: zod_1.z.number().int("User ID must be an integer").optional(),
});
exports.addPhotoSchema = zod_1.z.object({
    url: zod_1.z.string().url("Invalid URL format"),
});
exports.registerSchema = zod_1.z.object({
    email: zod_1.z.string().email("Invalid email address"),
    password: zod_1.z.string().min(6, "Password must be at least 6 characters long"),
    name: zod_1.z.string().optional(),
});
exports.loginSchema = zod_1.z.object({
    email: zod_1.z.string().email("Invalid email address"),
    password: zod_1.z.string().min(6, "Password must be at least 6 characters long"),
});
exports.syncPayloadSchema = zod_1.z.object({
    users: zod_1.z.array(zod_1.z.object({
        id: zod_1.z.number().int().optional(),
        email: zod_1.z.string().email(),
        name: zod_1.z.string().nullable().optional(), // Alterado para permitir null
        password: zod_1.z.string().nullable().optional(), // Alterado para permitir null
        createdAt: zod_1.z.string().datetime().nullable().optional(), // Alterado para permitir null
    })).optional(),
    inspections: zod_1.z.array(zod_1.z.object({
        id: zod_1.z.number().int().optional(),
        title: zod_1.z.string(),
        description: zod_1.z.string().nullable().optional(), // Alterado para permitir null
        status: zod_1.z.enum(['pending', 'completed', 'synced']),
        userId: zod_1.z.number().int(),
        createdAt: zod_1.z.string().datetime().nullable().optional(), // Alterado para permitir null
        updatedAt: zod_1.z.string().datetime().nullable().optional(), // Alterado para permitir null
    })).optional(),
    photos: zod_1.z.array(zod_1.z.object({
        id: zod_1.z.number().int().optional(),
        url: zod_1.z.string().url(),
        inspectionId: zod_1.z.number().int(),
        createdAt: zod_1.z.string().datetime().nullable().optional(), // Alterado para permitir null
    })).optional(),
});
