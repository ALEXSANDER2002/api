"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.syncService = void 0;
const prisma_1 = __importDefault(require("../prisma"));
const bcryptjs_1 = __importDefault(require("bcryptjs"));
// Função auxiliar para processar usuários
async function processUsers(users) {
    const syncedUsers = [];
    const conflicts = [];
    const processedEmails = new Set();
    const existingUsersInDb = await prisma_1.default.user.findMany({ select: { email: true, id: true } });
    const existingEmailsInDb = new Map(existingUsersInDb.map(u => [u.email, u.id]));
    for (const appUser of users || []) {
        try {
            if (appUser.email && processedEmails.has(appUser.email)) {
                conflicts.push({ type: 'user', data: appUser, error: 'User with this email already exists in this sync batch' });
                continue;
            }
            const dbId = appUser.email ? existingEmailsInDb.get(appUser.email) : undefined;
            if (!dbId && !appUser.id) {
                const userDataToProcess = {
                    email: appUser.email,
                    name: appUser.name,
                    password: appUser.password ? await bcryptjs_1.default.hash(appUser.password, 10) : undefined,
                };
                const newUser = await prisma_1.default.user.create({ data: userDataToProcess });
                syncedUsers.push(newUser);
                processedEmails.add(appUser.email);
                continue;
            }
            if (dbId && appUser.id && dbId === appUser.id) {
                const userDataToProcess = {
                    email: appUser.email,
                    name: appUser.name,
                    password: appUser.password ? await bcryptjs_1.default.hash(appUser.password, 10) : undefined,
                };
                const updatedUser = await prisma_1.default.user.update({ where: { id: appUser.id }, data: userDataToProcess });
                syncedUsers.push(updatedUser);
                processedEmails.add(appUser.email);
                continue;
            }
            if (dbId && (!appUser.id || dbId !== appUser.id)) {
                conflicts.push({ type: 'user', data: appUser, error: 'User with this email already exists' });
                continue;
            }
            if (!dbId && appUser.id) {
                const userDataToProcess = {
                    email: appUser.email,
                    name: appUser.name,
                    password: appUser.password ? await bcryptjs_1.default.hash(appUser.password, 10) : undefined,
                };
                const newUser = await prisma_1.default.user.create({ data: userDataToProcess });
                syncedUsers.push(newUser);
                processedEmails.add(appUser.email);
                continue;
            }
        }
        catch (error) {
            conflicts.push({ type: 'user', data: appUser, error: error.message });
        }
    }
    return { syncedUsers, conflicts };
}
// Função auxiliar para processar inspeções
async function processInspections(inspections) {
    const syncedInspections = [];
    const conflicts = [];
    for (const appInspection of inspections || []) {
        try {
            let existingInspection = null;
            let updateWhere = undefined;
            if (appInspection.id !== undefined && appInspection.id !== null) {
                existingInspection = await prisma_1.default.inspection.findUnique({ where: { id: appInspection.id } });
                updateWhere = { id: appInspection.id };
            }
            const inspectionDataToProcess = {
                title: appInspection.title,
                status: appInspection.status,
                user: { connect: { id: appInspection.userId } },
            };
            if (appInspection.description !== undefined) {
                inspectionDataToProcess.description = appInspection.description;
            }
            if (existingInspection && updateWhere) {
                const updatedInspection = await prisma_1.default.inspection.update({
                    where: updateWhere,
                    data: inspectionDataToProcess,
                });
                syncedInspections.push(updatedInspection);
            }
            else {
                const newInspection = await prisma_1.default.inspection.create({
                    data: inspectionDataToProcess,
                });
                syncedInspections.push(newInspection);
            }
        }
        catch (error) {
            conflicts.push({ type: 'inspection', data: appInspection, error: error.message });
        }
    }
    return { syncedInspections, conflicts };
}
// Função auxiliar para processar fotos
async function processPhotos(photos) {
    const syncedPhotos = [];
    const conflicts = [];
    for (const appPhoto of photos || []) {
        try {
            let existingPhoto = null;
            let updateWhere = undefined;
            if (appPhoto.id !== undefined && appPhoto.id !== null) {
                existingPhoto = await prisma_1.default.photo.findUnique({ where: { id: appPhoto.id } });
                updateWhere = { id: appPhoto.id };
            }
            if (existingPhoto && updateWhere) {
                const updateData = {};
                if (appPhoto.url !== undefined) {
                    updateData.url = appPhoto.url;
                }
                if (appPhoto.inspectionId !== undefined && appPhoto.inspectionId !== existingPhoto.inspectionId) {
                    updateData.inspection = { connect: { id: appPhoto.inspectionId } };
                }
                const updatedPhoto = await prisma_1.default.photo.update({
                    where: updateWhere,
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
                const newPhoto = await prisma_1.default.photo.create({
                    data: createData,
                });
                syncedPhotos.push(newPhoto);
            }
        }
        catch (error) {
            conflicts.push({ type: 'photo', data: appPhoto, error: error.message });
        }
    }
    return { syncedPhotos, conflicts };
}
exports.syncService = {
    /**
     * Synchronizes data from the mobile app to the backend.
     * @param payload The data payload from the app, containing arrays of users, inspections, and photos.
     * @returns A result object detailing synchronized data and any conflicts.
     */
    syncData: async (payload) => {
        const [userResult, inspectionResult, photoResult] = await Promise.all([
            processUsers(payload.users),
            processInspections(payload.inspections),
            processPhotos(payload.photos),
        ]);
        return {
            syncedUsers: userResult.syncedUsers,
            syncedInspections: inspectionResult.syncedInspections,
            syncedPhotos: photoResult.syncedPhotos,
            conflicts: [
                ...userResult.conflicts,
                ...inspectionResult.conflicts,
                ...photoResult.conflicts,
            ],
        };
    },
};
