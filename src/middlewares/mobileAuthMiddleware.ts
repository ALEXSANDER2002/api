import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';

interface AuthenticatedRequest extends Request {
  user?: any;
}

export const mobileAuthMiddleware = (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
  // Verificar se é uma requisição do mobile através de header customizado
  const clientType = req.headers['x-client-type'];
  const isMobileRequest = clientType === 'mobile' || clientType === 'app';

  // Se for mobile, permite acesso sem autenticação
  if (isMobileRequest) {
    console.log('📱 Requisição mobile detectada - acesso público permitido');
    return next();
  }

  // Se for web ou não especificado, exige autenticação
  console.log('🌐 Requisição web detectada - autenticação obrigatória');
  
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ 
      message: 'Token de autenticação obrigatório para acesso web',
      hint: 'Para acesso mobile, adicione o header: X-Client-Type: mobile'
    });
  }

  const token = authHeader.substring(7);
  
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your_jwt_secret_here');
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(401).json({ message: 'Token inválido' });
  }
}; 