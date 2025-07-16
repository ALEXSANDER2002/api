import { Request, Response, NextFunction } from 'express';

interface AuthenticatedRequest extends Request {
  userId?: number;
  userRole?: 'USER' | 'ADMIN'; // Adicionado para armazenar a role do usuário
}

export const authorize = (allowedRoles: Array<'USER' | 'ADMIN'>) => {
  return (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
    // O userRole deve ser definido pelo authMiddleware antes deste middleware
    const userRole = req.userRole;

    if (!userRole || !allowedRoles.includes(userRole)) {
      return res.status(403).json({ message: 'Forbidden: Insufficient permissions' });
    }
    console.log('AUTHZ LOG req.userRole:', req.userRole, 'req.userId:', req.userId);
    next();
  };
}; 