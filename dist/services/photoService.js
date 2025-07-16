"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.photoService = void 0;
const app_1 = require("../app");
exports.photoService = {
    /**
     * Adds a new photo to an inspection.
     * @param inspectionId The ID of the inspection to which the photo belongs.
     * @param url The URL of the photo.
     * @returns The created photo object.
     */
    addPhoto: async (inspectionId, url) => {
        return app_1.prisma.photo.create({
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
        return app_1.prisma.photo.findMany({
            where: { inspectionId },
        });
    },
    /**
     * Deletes a photo by its ID.
     * @param id The ID of the photo to delete.
     * @returns The deleted photo object.
     */
    deletePhoto: async (id) => {
        return app_1.prisma.photo.delete({
            where: { id },
        });
    },
};
