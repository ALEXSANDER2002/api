"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.syncService = void 0;
const app_1 = require("../app");
const bcryptjs_1 = __importDefault(require("bcryptjs"));
exports.syncService = {
    /**
     * Synchronizes data from the mobile app to the backend.
     * @param payload The data payload from the app, containing arrays of users, inspections, and photos.
     * @returns A result object detailing synchronized data and any conflicts.
     */
    syncData: async (payload) => {
        const syncedUsers = [];
        const syncedInspections = [];
        const syncedPhotos = [];
        const conflicts = [];
        // Process Users
        for (const appUser of payload.users || []) {
            try {
                const existingUser = await app_1.prisma.user.findUnique({ where: { id: appUser.id } });
                const userDataToProcess = {
                    email: appUser.email,
                };
                if (appUser.name !== undefined) {
                    userDataToProcess.name = appUser.name;
                }
                if (appUser.password !== undefined) {
                    if (appUser.password !== null) {
                        userDataToProcess.password = await bcryptjs_1.default.hash(appUser.password, 10);
                    }
                    else {
                        userDataToProcess.password = null; // Explicitly set to null if provided as null
                    }
                }
                if (existingUser) {
                    const updatedUser = await app_1.prisma.user.update({
                        where: { id: appUser.id },
                        data: userDataToProcess,
                    });
                    syncedUsers.push(updatedUser);
                }
                else {
                    const newUser = await app_1.prisma.user.create({
                        data: userDataToProcess, // Já é do tipo correto
                    });
                    syncedUsers.push(newUser);
                }
            }
            catch (error) {
                conflicts.push({ type: 'user', data: appUser, error: error.message });
            }
        }
        // Process Inspections
        for (const appInspection of payload.inspections || []) {
            try {
                const existingInspection = await app_1.prisma.inspection.findUnique({ where: { id: appInspection.id } });
                const inspectionDataToProcess = {
                    title: appInspection.title,
                    status: appInspection.status,
                    user: { connect: { id: appInspection.userId } }, // Alterado para usar relação 'user'
                };
                if (appInspection.description !== undefined) {
                    inspectionDataToProcess.description = appInspection.description;
                }
                if (existingInspection) {
                    const updatedInspection = await app_1.prisma.inspection.update({
                        where: { id: appInspection.id },
                        data: inspectionDataToProcess, // Já é do tipo correto
                    });
                    syncedInspections.push(updatedInspection);
                }
                else {
                    const newInspection = await app_1.prisma.inspection.create({
                        data: inspectionDataToProcess, // Já é do tipo correto
                    });
                    syncedInspections.push(newInspection);
                }
            }
            catch (error) {
                conflicts.push({ type: 'inspection', data: appInspection, error: error.message });
            }
        }
        // Process Photos
        for (const appPhoto of payload.photos || []) {
            try {
                const existingPhoto = await app_1.prisma.photo.findUnique({ where: { id: appPhoto.id } });
                if (existingPhoto) {
                    const updateData = {};
                    if (appPhoto.url !== undefined) {
                        updateData.url = appPhoto.url;
                    }
                    if (appPhoto.inspectionId !== undefined && appPhoto.inspectionId !== existingPhoto.inspectionId) {
                        updateData.inspection = { connect: { id: appPhoto.inspectionId } };
                    }
                    const updatedPhoto = await app_1.prisma.photo.update({
                        where: { id: appPhoto.id },
                        data: updateData,
                    });
                    syncedPhotos.push(updatedPhoto);
                }
                else {
                    const createData = {
                        url: appPhoto.url,
                        inspection: {
                            connect: { id: appPhoto.inspectionId },
                        },
                    };
                    const newPhoto = await app_1.prisma.photo.create({
                        data: createData, // Já é do tipo correto
                    });
                    syncedPhotos.push(newPhoto);
                }
            }
            catch (error) {
                conflicts.push({ type: 'photo', data: appPhoto, error: error.message });
            }
        }
        return { syncedUsers, syncedInspections, syncedPhotos, conflicts };
    },
};
