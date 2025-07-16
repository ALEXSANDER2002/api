import { Request, Response, NextFunction } from 'express';
import { authService } from '../services/authService';

interface AuthenticatedRequest extends Request {
  userId?: number;
  userRole?: 'USER' | 'ADMIN'; // Adicionado para armazenar a role do usuário
}

export const authMiddleware = (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'No token provided' });
  }

  const token = authHeader.split(' ')[1];

  try {
    const decodedToken = authService.verifyToken(token);
    req.userId = decodedToken.userId; // Attach user ID to the request object
    req.userRole = decodedToken.role; // Attach user role to the request object
    next();
  } catch (error) {
    if (error instanceof Error && error.message.includes('Invalid or expired token')) {
      return res.status(401).json({ message: error.message });
    }
    console.error('Authentication error:', error);
    res.status(500).json({ message: 'Failed to authenticate token' });
  }
}; 