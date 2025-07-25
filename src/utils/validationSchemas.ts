import { z } from 'zod';

export const createUserSchema = z.object({
  email: z.string().email("Invalid email address"),
  name: z.string().optional(),
  password: z.string().min(6, "Password must be at least 6 characters long"),
});

export const updateUserSchema = z.object({
  email: z.string().email("Invalid email address").optional(),
  name: z.string().optional(),
  password: z.string().min(6, "Password must be at least 6 characters long").optional(),
});

export type CreateUserInput = z.infer<typeof createUserSchema>;
export type UpdateUserInput = z.infer<typeof updateUserSchema>;

export const createInspectionSchema = z.object({
  title: z.string().min(1, "Title is required"),
  description: z.string().optional(),
  status: z.enum(['pending', 'completed', 'synced'], { message: "Invalid status" }),
  userId: z.number().int("User ID must be an integer"),
});

export const updateInspectionSchema = z.object({
  title: z.string().min(1, "Title is required").optional(),
  description: z.string().optional(),
  status: z.enum(['pending', 'completed', 'synced'], { message: "Invalid status" }).optional(),
  userId: z.number().int("User ID must be an integer").optional(),
});

export type CreateInspectionInput = z.infer<typeof createInspectionSchema>;
export type UpdateInspectionInput = z.infer<typeof updateInspectionSchema>;

export const addPhotoSchema = z.object({
  url: z.string().url("Invalid URL format"),
});

export type AddPhotoInput = z.infer<typeof addPhotoSchema>;

export const registerSchema = z.object({
  email: z.string().email("Invalid email address"),
  password: z.string().min(6, "Password must be at least 6 characters long"),
  name: z.string().optional(),
  role: z.enum(['USER', 'ADMIN']).optional(),
});

export const loginSchema = z.object({
  email: z.string().email("Invalid email address"),
  password: z.string().min(6, "Password must be at least 6 characters long"),
});

export type RegisterInput = z.infer<typeof registerSchema>;
export type LoginInput = z.infer<typeof loginSchema>;

// Schema mais flexível para sincronização mobile
export const syncPayloadSchema = z.object({
  users: z.array(z.object({
    id: z.number().int().optional(),
    email: z.string().email().optional(), // Email opcional para mobile
    name: z.string().nullable().optional(),
    password: z.string().nullable().optional(),
    createdAt: z.string().datetime().nullable().optional(),
    updatedAt: z.string().datetime().nullable().optional(),
    // Campos adicionais que podem vir do mobile
    inspectionType: z.string().optional(),
    inspectorName: z.string().optional(),
    location: z.string().optional(),
    notes: z.string().nullable().optional(),
    isDeleted: z.boolean().optional(),
    isSynced: z.boolean().optional(),
    syncedAt: z.string().datetime().nullable().optional(),
    serverId: z.number().int().nullable().optional(),
  })).optional().default([]),
  inspections: z.array(z.object({
    id: z.number().int().optional(),
    title: z.string().optional(), // Título opcional
    description: z.string().nullable().optional(),
    status: z.enum(['pending', 'completed', 'synced']).optional(), // Status opcional
    userId: z.number().int().optional(), // UserId opcional
    createdAt: z.string().datetime().nullable().optional(),
    updatedAt: z.string().datetime().nullable().optional(),
    // Campos adicionais que podem vir do mobile
    inspectionType: z.string().optional(),
    inspectorName: z.string().optional(),
    location: z.string().optional(),
    notes: z.string().nullable().optional(),
    isDeleted: z.boolean().optional(),
    isSynced: z.boolean().optional(),
    syncedAt: z.string().datetime().nullable().optional(),
    serverId: z.number().int().nullable().optional(),
    inspectionDate: z.string().datetime().nullable().optional(),
  })).optional().default([]),
  photos: z.array(z.object({
    id: z.number().int().optional(),
    url: z.string().url().optional(), // URL opcional
    inspectionId: z.number().int().optional(), // InspectionId opcional
    createdAt: z.string().datetime().nullable().optional(),
    updatedAt: z.string().datetime().nullable().optional(),
  })).optional().default([]),
  // Campo adicional para checklist items
  checklistItems: z.array(z.object({
    id: z.number().int().optional(),
    inspectionId: z.number().int().optional(),
    title: z.string().optional(),
    status: z.string().optional(),
    notes: z.string().nullable().optional(),
    createdAt: z.string().datetime().nullable().optional(),
    updatedAt: z.string().datetime().nullable().optional(),
  })).optional().default([]),
});

export type SyncPayloadInput = z.infer<typeof syncPayloadSchema>; 