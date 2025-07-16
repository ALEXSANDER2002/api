"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.errorHandler = void 0;
const zod_1 = require("zod");
const errorHandler = (err, req, res, next) => {
    console.error('API Error:', err);
    if (err instanceof zod_1.ZodError) {
        return res.status(400).json({
            message: 'Validation Error',
            errors: err.issues,
        });
    }
    if (err.message.includes('Record to delete does not exist')) {
        return res.status(404).json({ message: 'Not Found: Record does not exist' });
    }
    if (err.message.includes('Unique constraint failed')) {
        return res.status(409).json({ message: 'Conflict: A record with this unique identifier already exists.' });
    }
    // Handle JWT errors from authMiddleware more gracefully
    if (err.message.includes('Invalid or expired token')) {
        return res.status(401).json({ message: err.message });
    }
    // Prisma Client known request errors (P2000 family)
    // For more specific error handling, you might check err.code (e.g., if (err.code === 'P2002'))
    if (err.code && err.code.startsWith('P')) {
        switch (err.code) {
            case 'P2025': // Record not found
                return res.status(404).json({ message: 'Not Found: The requested record does not exist.' });
            case 'P2002': // Unique constraint violation
                return res.status(409).json({ message: 'Conflict: A record with this unique identifier already exists.' });
            // Add more cases for other Prisma errors as needed
            default:
                return res.status(400).json({ message: `Database error: ${err.message}` });
        }
    }
    const statusCode = err.statusCode || 500;
    const message = err.message || 'Internal Server Error';
    res.status(statusCode).json({
        message,
    });
};
exports.errorHandler = errorHandler;
