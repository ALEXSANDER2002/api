import prisma from '../prisma';
import bcrypt from 'bcryptjs';
import { User, Inspection, Photo, Prisma } from '@prisma/client';
import { SyncPayloadInput } from '../utils/validationSchemas';

// Tipos para conflitos
interface SyncConflict {
  type: 'user' | 'inspection' | 'photo' | 'checklistItem';
  data: any;
  error: string;
}

interface SyncResult {
  syncedUsers: User[];
  syncedInspections: Inspection[];
  syncedPhotos: Photo[];
  conflicts: SyncConflict[];
}

// Função auxiliar para processar usuários
async function processUsers(users: SyncPayloadInput['users']): Promise<{ syncedUsers: User[]; conflicts: SyncConflict[] }> {
  const syncedUsers: User[] = [];
  const conflicts: SyncConflict[] = [];
  const processedEmails = new Set<string>();
  const existingUsersInDb = await prisma.user.findMany({ select: { email: true, id: true } });
  const existingEmailsInDb = new Map(existingUsersInDb.map(u => [u.email, u.id]));
  
  for (const appUser of users || []) {
    try {
      // Se não tem email, pular
      if (!appUser.email) {
        conflicts.push({ type: 'user', data: appUser, error: 'Email é obrigatório para usuários' });
        continue;
      }

      if (processedEmails.has(appUser.email)) {
        conflicts.push({ type: 'user', data: appUser, error: 'User with this email already exists in this sync batch' });
        continue;
      }

      const dbId = existingEmailsInDb.get(appUser.email);

      if (!dbId && !appUser.id) {
        // Criar novo usuário
        const userDataToProcess: Prisma.UserCreateInput = {
          email: appUser.email,
          name: appUser.name || 'Usuário Mobile',
          password: appUser.password ? await bcrypt.hash(appUser.password, 10) : undefined,
        };
        const newUser = await prisma.user.create({ data: userDataToProcess });
        syncedUsers.push(newUser);
        processedEmails.add(appUser.email);
        continue;
      }

      if (dbId && appUser.id && dbId === appUser.id) {
        // Atualizar usuário existente
        const userDataToProcess: Prisma.UserUpdateInput = {
          email: appUser.email,
          name: appUser.name,
          password: appUser.password ? await bcrypt.hash(appUser.password, 10) : undefined,
        };
        const updatedUser = await prisma.user.update({ where: { id: appUser.id }, data: userDataToProcess });
        syncedUsers.push(updatedUser);
        processedEmails.add(appUser.email);
        continue;
      }

      if (dbId && (!appUser.id || dbId !== appUser.id)) {
        conflicts.push({ type: 'user', data: appUser, error: 'User with this email already exists' });
        continue;
      }

      if (!dbId && appUser.id) {
        // Criar usuário com ID específico (se possível)
        const userDataToProcess: Prisma.UserCreateInput = {
          email: appUser.email,
          name: appUser.name || 'Usuário Mobile',
          password: appUser.password ? await bcrypt.hash(appUser.password, 10) : undefined,
        };
        const newUser = await prisma.user.create({ data: userDataToProcess });
        syncedUsers.push(newUser);
        processedEmails.add(appUser.email);
        continue;
      }
    } catch (error: any) {
      conflicts.push({ type: 'user', data: appUser, error: error.message });
    }
  }
  return { syncedUsers, conflicts };
}

// Função auxiliar para processar inspeções
async function processInspections(inspections: SyncPayloadInput['inspections']): Promise<{ syncedInspections: Inspection[]; conflicts: SyncConflict[] }> {
  const syncedInspections: Inspection[] = [];
  const conflicts: SyncConflict[] = [];
  
  for (const appInspection of inspections || []) {
    try {
      // Validar campos obrigatórios
      if (!appInspection.title) {
        conflicts.push({ type: 'inspection', data: appInspection, error: 'Title is required' });
        continue;
      }

      if (!appInspection.userId) {
        conflicts.push({ type: 'inspection', data: appInspection, error: 'UserId is required' });
        continue;
      }

      let existingInspection = null;
      let updateWhere = undefined;
      
      if (appInspection.id !== undefined && appInspection.id !== null) {
        existingInspection = await prisma.inspection.findUnique({ where: { id: appInspection.id } });
        updateWhere = { id: appInspection.id };
      }

      const inspectionDataToProcess: Prisma.InspectionCreateInput = {
        title: appInspection.title,
        status: appInspection.status || 'completed',
        user: { connect: { id: appInspection.userId } },
      };

      if (appInspection.description !== undefined) {
        inspectionDataToProcess.description = appInspection.description;
      }

      if (existingInspection && updateWhere) {
        const updatedInspection = await prisma.inspection.update({
          where: updateWhere,
          data: inspectionDataToProcess,
        });
        syncedInspections.push(updatedInspection);
      } else {
        const newInspection = await prisma.inspection.create({
          data: inspectionDataToProcess,
        });
        syncedInspections.push(newInspection);
      }
    } catch (error: any) {
      conflicts.push({ type: 'inspection', data: appInspection, error: error.message });
    }
  }
  return { syncedInspections, conflicts };
}

// Função auxiliar para processar fotos
async function processPhotos(photos: SyncPayloadInput['photos']): Promise<{ syncedPhotos: Photo[]; conflicts: SyncConflict[] }> {
  const syncedPhotos: Photo[] = [];
  const conflicts: SyncConflict[] = [];
  
  for (const appPhoto of photos || []) {
    try {
      // Validar campos obrigatórios
      if (!appPhoto.url) {
        conflicts.push({ type: 'photo', data: appPhoto, error: 'URL is required' });
        continue;
      }

      if (!appPhoto.inspectionId) {
        conflicts.push({ type: 'photo', data: appPhoto, error: 'InspectionId is required' });
        continue;
      }

      let existingPhoto = null;
      let updateWhere = undefined;
      
      if (appPhoto.id !== undefined && appPhoto.id !== null) {
        existingPhoto = await prisma.photo.findUnique({ where: { id: appPhoto.id } });
        updateWhere = { id: appPhoto.id };
      }

      if (existingPhoto && updateWhere) {
        const updateData: Prisma.PhotoUpdateInput = {};
        if (appPhoto.url !== undefined) {
          updateData.url = appPhoto.url;
        }
        if (appPhoto.inspectionId !== undefined && appPhoto.inspectionId !== existingPhoto.inspectionId) {
          updateData.inspection = { connect: { id: appPhoto.inspectionId } };
        }
        const updatedPhoto = await prisma.photo.update({
          where: updateWhere,
          data: updateData,
        });
        syncedPhotos.push(updatedPhoto);
      } else {
        const createData: Prisma.PhotoCreateInput = {
          url: appPhoto.url,
          inspection: {
            connect: { id: appPhoto.inspectionId },
          },
        };
        const newPhoto = await prisma.photo.create({
          data: createData,
        });
        syncedPhotos.push(newPhoto);
      }
    } catch (error: any) {
      conflicts.push({ type: 'photo', data: appPhoto, error: error.message });
    }
  }
  return { syncedPhotos, conflicts };
}

// Função auxiliar para processar checklist items (se existir tabela)
async function processChecklistItems(checklistItems: SyncPayloadInput['checklistItems']): Promise<{ conflicts: SyncConflict[] }> {
  const conflicts: SyncConflict[] = [];
  
  // Por enquanto, apenas log dos items (não há tabela no schema)
  for (const item of checklistItems || []) {
    console.log('📝 Checklist item recebido:', item);
    // TODO: Implementar quando houver tabela de checklist items
  }
  
  return { conflicts };
}

export const syncService = {
  /**
   * Synchronizes data from the mobile app to the backend.
   * @param payload The data payload from the app, containing arrays of users, inspections, and photos.
   * @returns A result object detailing synchronized data and any conflicts.
   */
  syncData: async (payload: SyncPayloadInput): Promise<SyncResult> => {
    console.log('🔄 Iniciando sincronização com payload:', {
      users: payload.users?.length || 0,
      inspections: payload.inspections?.length || 0,
      photos: payload.photos?.length || 0,
      checklistItems: payload.checklistItems?.length || 0,
    });

    const [userResult, inspectionResult, photoResult, checklistResult] = await Promise.all([
      processUsers(payload.users),
      processInspections(payload.inspections),
      processPhotos(payload.photos),
      processChecklistItems(payload.checklistItems),
    ]);

    const result = {
      syncedUsers: userResult.syncedUsers,
      syncedInspections: inspectionResult.syncedInspections,
      syncedPhotos: photoResult.syncedPhotos,
      conflicts: [
        ...userResult.conflicts,
        ...inspectionResult.conflicts,
        ...photoResult.conflicts,
        ...checklistResult.conflicts,
      ],
    };

    console.log('✅ Sincronização concluída:', {
      syncedUsers: result.syncedUsers.length,
      syncedInspections: result.syncedInspections.length,
      syncedPhotos: result.syncedPhotos.length,
      conflicts: result.conflicts.length,
    });

    return result;
  },
}; 