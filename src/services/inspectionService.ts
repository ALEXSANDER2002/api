import prisma from '../prisma';

export const inspectionService = {
  /**
   * Creates a new inspection.
   * @param data Inspection data including title, description (optional), status, and userId.
   * @returns The created inspection object.
   */
  createInspection: async (data: { title: string; description?: string; status: string; userId: number }) => {
    return prisma.inspection.create({
      data,
    });
  },

  /**
   * Retrieves all inspections.
   * @returns An array of inspection objects.
   */
  getAllInspections: async () => {
    return prisma.inspection.findMany();
  },

  /**
   * Retrieves an inspection by its ID.
   * @param id The ID of the inspection to retrieve.
   * @returns The inspection object, or null if not found.
   */
  getInspectionById: async (id: number) => {
    return prisma.inspection.findUnique({
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
  updateInspection: async (id: number, data: { title?: string; description?: string; status?: string; userId?: number }) => {
    return prisma.inspection.update({
      where: { id },
      data,
    });
  },

  /**
   * Deletes an inspection by its ID.
   * @param id The ID of the inspection to delete.
   * @returns The deleted inspection object.
   */
  deleteInspection: async (id: number) => {
    // Delete related photos first to avoid foreign key constraints
    await prisma.photo.deleteMany({
      where: { inspectionId: id },
    });
    return prisma.inspection.delete({
      where: { id },
    });
  },
}; 