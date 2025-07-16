"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.authorize = void 0;
const authorize = (allowedRoles) => {
    return (req, res, next) => {
        // O userRole deve ser definido pelo authMiddleware antes deste middleware
        const userRole = req.userRole;
        if (!userRole || !allowedRoles.includes(userRole)) {
            return res.status(403).json({ message: 'Forbidden: Insufficient permissions' });
        }
        console.log('AUTHZ LOG req.userRole:', req.userRole, 'req.userId:', req.userId);
        next();
    };
};
exports.authorize = authorize;
