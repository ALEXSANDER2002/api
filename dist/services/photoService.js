"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.photoService = void 0;
const prisma_1 = __importDefault(require("../prisma"));
exports.photoService = {
    /**
     * Adds a new photo to an inspection.
     * @param inspectionId The ID of the inspection to which the photo belongs.
     * @param url The URL of the photo.
     * @returns The created photo object.
     */
    addPhoto: async (inspectionId, url) => {
        return prisma_1.default.photo.create({
            data: {
                url,
                inspection: {
                    connect: { id: inspectionId },
                },
            },
        });
    },
    /**
     * Retrieves all photos for a specific inspection.
     * @param inspectionId The ID of the inspection.
     * @returns An array of photo objects.
     */
    getPhotosByInspectionId: async (inspectionId) => {
        return prisma_1.default.photo.findMany({
            where: { inspectionId },
        });
    },
    /**
     * Deletes a photo by its ID.
     * @param id The ID of the photo to delete.
     * @returns The deleted photo object, or null if not found.
     */
    deletePhoto: async (id) => {
        const photo = await prisma_1.default.photo.findUnique({ where: { id } });
        if (!photo)
            return null;
        await prisma_1.default.photo.delete({ where: { id } });
        return photo;
    },
};
