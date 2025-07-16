"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.inspectionService = void 0;
const app_1 = require("../app");
exports.inspectionService = {
    /**
     * Creates a new inspection.
     * @param data Inspection data including title, description (optional), status, and userId.
     * @returns The created inspection object.
     */
    createInspection: async (data) => {
        return app_1.prisma.inspection.create({
            data,
        });
    },
    /**
     * Retrieves all inspections.
     * @returns An array of inspection objects.
     */
    getAllInspections: async () => {
        return app_1.prisma.inspection.findMany();
    },
    /**
     * Retrieves an inspection by its ID.
     * @param id The ID of the inspection to retrieve.
     * @returns The inspection object, or null if not found.
     */
    getInspectionById: async (id) => {
        return app_1.prisma.inspection.findUnique({
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
        return app_1.prisma.inspection.update({
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
        await app_1.prisma.photo.deleteMany({
            where: { inspectionId: id },
        });
        return app_1.prisma.inspection.delete({
            where: { id },
        });
    },
};
