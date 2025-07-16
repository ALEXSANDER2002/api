"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.inspectionService = void 0;
const prisma_1 = __importDefault(require("../prisma"));
exports.inspectionService = {
    /**
     * Creates a new inspection.
     * @param data Inspection data including title, description (optional), status, and userId.
     * @returns The created inspection object.
     */
    createInspection: async (data) => {
        return prisma_1.default.inspection.create({
            data,
        });
    },
    /**
     * Retrieves all inspections.
     * @returns An array of inspection objects.
     */
    getAllInspections: async () => {
        return prisma_1.default.inspection.findMany();
    },
    /**
     * Retrieves an inspection by its ID.
     * @param id The ID of the inspection to retrieve.
     * @returns The inspection object, or null if not found.
     */
    getInspectionById: async (id) => {
        return prisma_1.default.inspection.findUnique({
            where: { id },
            include: { photos: true, user: { select: { id: true, email: true, name: true } } }, // Include related data
        });
    },
    /**
     * Updates an existing inspection.
     * @param id The ID of the inspection to update.
     * @param data New inspection data.
     * @returns The updated inspection object.
     */
    updateInspection: async (id, data) => {
        return prisma_1.default.inspection.update({
            where: { id },
            data,
        });
    },
    /**
     * Deletes an inspection by its ID.
     * @param id The ID of the inspection to delete.
     * @returns The deleted inspection object.
     */
    deleteInspection: async (id) => {
        // Delete related photos first to avoid foreign key constraints
        await prisma_1.default.photo.deleteMany({
            where: { inspectionId: id },
        });
        return prisma_1.default.inspection.delete({
            where: { id },
        });
    },
};
