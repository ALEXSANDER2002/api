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
    role: zod_1.z.enum(['USER', 'ADMIN']).optional(),
});
exports.loginSchema = zod_1.z.object({
    email: zod_1.z.string().email("Invalid email address"),
    password: zod_1.z.string().min(6, "Password must be at least 6 characters long"),
});
// Schema mais flexível para sincronização mobile
exports.syncPayloadSchema = zod_1.z.object({
    users: zod_1.z.array(zod_1.z.object({
        id: zod_1.z.number().int().optional(),
        email: zod_1.z.string().email().optional(), // Email opcional para mobile
        name: zod_1.z.string().nullable().optional(),
        password: zod_1.z.string().nullable().optional(),
        createdAt: zod_1.z.string().datetime().nullable().optional(),
        updatedAt: zod_1.z.string().datetime().nullable().optional(),
        // Campos adicionais que podem vir do mobile
        inspectionType: zod_1.z.string().optional(),
        inspectorName: zod_1.z.string().optional(),
        location: zod_1.z.string().optional(),
        notes: zod_1.z.string().nullable().optional(),
        isDeleted: zod_1.z.boolean().optional(),
        isSynced: zod_1.z.boolean().optional(),
        syncedAt: zod_1.z.string().datetime().nullable().optional(),
        serverId: zod_1.z.number().int().nullable().optional(),
    })).optional().default([]),
    inspections: zod_1.z.array(zod_1.z.object({
        id: zod_1.z.number().int().optional(),
        title: zod_1.z.string().optional(), // Título opcional
        description: zod_1.z.string().nullable().optional(),
        status: zod_1.z.enum(['pending', 'completed', 'synced']).optional(), // Status opcional
        userId: zod_1.z.number().int().optional(), // UserId opcional
        createdAt: zod_1.z.string().datetime().nullable().optional(),
        updatedAt: zod_1.z.string().datetime().nullable().optional(),
        // Campos adicionais que podem vir do mobile
        inspectionType: zod_1.z.string().optional(),
        inspectorName: zod_1.z.string().optional(),
        location: zod_1.z.string().optional(),
        notes: zod_1.z.string().nullable().optional(),
        isDeleted: zod_1.z.boolean().optional(),
        isSynced: zod_1.z.boolean().optional(),
        syncedAt: zod_1.z.string().datetime().nullable().optional(),
        serverId: zod_1.z.number().int().nullable().optional(),
        inspectionDate: zod_1.z.string().datetime().nullable().optional(),
    })).optional().default([]),
    photos: zod_1.z.array(zod_1.z.object({
        id: zod_1.z.number().int().optional(),
        url: zod_1.z.string().url().optional(), // URL opcional
        inspectionId: zod_1.z.number().int().optional(), // InspectionId opcional
        createdAt: zod_1.z.string().datetime().nullable().optional(),
        updatedAt: zod_1.z.string().datetime().nullable().optional(),
    })).optional().default([]),
    // Campo adicional para checklist items
    checklistItems: zod_1.z.array(zod_1.z.object({
        id: zod_1.z.number().int().optional(),
        inspectionId: zod_1.z.number().int().optional(),
        title: zod_1.z.string().optional(),
        status: zod_1.z.string().optional(),
        notes: zod_1.z.string().nullable().optional(),
        createdAt: zod_1.z.string().datetime().nullable().optional(),
        updatedAt: zod_1.z.string().datetime().nullable().optional(),
    })).optional().default([]),
});
