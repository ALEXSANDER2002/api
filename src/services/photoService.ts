import prisma from '../prisma';

export const photoService = {
  /**
   * Adds a new photo to an inspection.
   * @param inspectionId The ID of the inspection to which the photo belongs.
   * @param url The URL of the photo.
   * @returns The created photo object.
   */
  addPhoto: async (inspectionId: number, url: string) => {
    return prisma.photo.create({
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
  getPhotosByInspectionId: async (inspectionId: number) => {
    return prisma.photo.findMany({
      where: { inspectionId },
    });
  },

  /**
   * Deletes a photo by its ID.
   * @param id The ID of the photo to delete.
   * @returns The deleted photo object, or null if not found.
   */
  deletePhoto: async (id: number) => {
    const photo = await prisma.photo.findUnique({ where: { id } });
    if (!photo) return null;
    await prisma.photo.delete({ where: { id } });
    return photo;
  },
}; 