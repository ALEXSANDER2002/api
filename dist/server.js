"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const app_1 = __importDefault(require("./app")); // Importa a instância do app e do prisma
const swagger_ui_express_1 = __importDefault(require("swagger-ui-express"));
const swagger_jsdoc_1 = __importDefault(require("swagger-jsdoc"));
const PORT = process.env.PORT || 3000;
// Swagger Configuration
const swaggerOptions = {
    definition: {
        openapi: '3.0.0',
        info: {
            title: 'API de Inspeções',
            version: '1.0.0',
            description: 'Documentação da API Express + Prisma + MySQL para o sistema Ronda Check',
        },
        servers: [
            { url: "http://rondacheck.com.br" }
        ],
        components: {
            securitySchemes: {
                bearerAuth: {
                    type: 'http',
                    scheme: 'bearer',
                    bearerFormat: 'JWT',
                },
            },
            schemas: {
                User: {
                    type: 'object',
                    properties: {
                        id: { type: 'integer' },
                        email: { type: 'string' },
                        name: { type: 'string' },
                        createdAt: { type: 'string', format: 'date-time' },
                        role: { type: 'string', enum: ['USER', 'ADMIN'], default: 'USER' },
                    },
                },
                UserInput: {
                    type: 'object',
                    properties: {
                        email: { type: 'string' },
                        name: { type: 'string' },
                        password: { type: 'string' },
                    },
                    required: ['email', 'password'],
                },
                UserUpdateInput: {
                    type: 'object',
                    properties: {
                        email: { type: 'string' },
                        name: { type: 'string' },
                        password: { type: 'string' },
                    },
                },
                Inspection: {
                    type: 'object',
                    properties: {
                        id: { type: 'integer' },
                        title: { type: 'string' },
                        description: { type: 'string' },
                        status: { type: 'string' },
                        userId: { type: 'integer' },
                        createdAt: { type: 'string', format: 'date-time' },
                        updatedAt: { type: 'string', format: 'date-time' },
                    },
                },
                InspectionInput: {
                    type: 'object',
                    properties: {
                        title: { type: 'string' },
                        description: { type: 'string' },
                        status: { type: 'string' },
                        userId: { type: 'integer' },
                    },
                    required: ['title', 'status', 'userId'],
                },
                InspectionUpdateInput: {
                    type: 'object',
                    properties: {
                        title: { type: 'string' },
                        description: { type: 'string' },
                        status: { type: 'string' },
                        userId: { type: 'integer' },
                    },
                },
                Photo: {
                    type: 'object',
                    properties: {
                        id: { type: 'integer' },
                        url: { type: 'string' },
                        inspectionId: { type: 'integer' },
                        createdAt: { type: 'string', format: 'date-time' },
                    },
                },
                PhotoInput: {
                    type: 'object',
                    properties: {
                        url: { type: 'string' },
                    },
                    required: ['url'],
                },
                RegisterInput: {
                    type: 'object',
                    properties: {
                        email: { type: 'string' },
                        password: { type: 'string' },
                        name: { type: 'string' },
                    },
                    required: ['email', 'password'],
                },
                LoginInput: {
                    type: 'object',
                    properties: {
                        email: { type: 'string' },
                        password: { type: 'string' },
                    },
                    required: ['email', 'password'],
                },
                SyncPayload: {
                    type: 'object',
                    properties: {
                        users: {
                            type: 'array',
                            items: {
                                type: 'object',
                                properties: {
                                    id: { type: 'integer', format: 'int64', description: 'Optional ID for existing users' },
                                    email: { type: 'string', format: 'email' },
                                    name: { type: 'string', nullable: true },
                                    password: { type: 'string', nullable: true, description: 'Hashed password for new or updated users' },
                                    createdAt: { type: 'string', format: 'date-time', nullable: true },
                                },
                                required: ['email'],
                            },
                            description: 'Array of user data to synchronize',
                            example: [
                                { "email": "user1@email.com", "name": "User 1", "password": "senha123" },
                                { "id": 2, "email": "user2@email.com", "name": "User 2" }
                            ]
                        },
                        inspections: {
                            type: 'array',
                            items: {
                                type: 'object',
                                properties: {
                                    id: { type: 'integer', format: 'int64', description: 'Optional ID for existing inspections' },
                                    title: { type: 'string' },
                                    description: { type: 'string', nullable: true },
                                    status: { type: 'string', enum: ['pending', 'completed', 'synced'] },
                                    userId: { type: 'integer', format: 'int64' },
                                    createdAt: { type: 'string', format: 'date-time', nullable: true },
                                    updatedAt: { type: 'string', format: 'date-time', nullable: true },
                                },
                                required: ['title', 'status', 'userId'],
                            },
                            description: 'Array of inspection data to synchronize',
                            example: [
                                { "title": "Inspeção 1", "status": "pending", "userId": 1 },
                                { "id": 2, "title": "Inspeção 2", "status": "completed", "userId": 2 }
                            ]
                        },
                        photos: {
                            type: 'array',
                            items: {
                                type: 'object',
                                properties: {
                                    id: { type: 'integer', format: 'int64', description: 'Optional ID for existing photos' },
                                    url: { type: 'string', format: 'url' },
                                    inspectionId: { type: 'integer', format: 'int64' },
                                    createdAt: { type: 'string', format: 'date-time', nullable: true },
                                },
                                required: ['url', 'inspectionId'],
                            },
                            description: 'Array of photo data to synchronize',
                            example: [
                                { "url": "https://site.com/foto1.jpg", "inspectionId": 1 },
                                { "id": 2, "url": "https://site.com/foto2.jpg", "inspectionId": 2 }
                            ]
                        },
                    },
                    description: 'Payload enviado pelo app para sincronização. Se o id for omitido, será criado um novo registro. Se o id existir, será atualizado.',
                    example: {
                        users: [
                            { email: 'user1@email.com', name: 'User 1', password: 'senha123' },
                            { id: 2, email: 'user2@email.com', name: 'User 2' }
                        ],
                        inspections: [
                            { title: 'Inspeção 1', status: 'pending', userId: 1 },
                            { id: 2, title: 'Inspeção 2', status: 'completed', userId: 2 }
                        ],
                        photos: [
                            { url: 'https://site.com/foto1.jpg', inspectionId: 1 },
                            { id: 2, url: 'https://site.com/foto2.jpg', inspectionId: 2 }
                        ]
                    }
                },
                SyncResult: {
                    type: 'object',
                    properties: {
                        syncedUsers: {
                            type: 'array',
                            items: { $ref: '#/components/schemas/User' },
                            description: 'Users successfully synchronized',
                            example: [
                                { id: 1, email: 'user1@email.com', name: 'User 1', role: 'USER', createdAt: '2024-07-15T12:00:00Z' }
                            ]
                        },
                        syncedInspections: {
                            type: 'array',
                            items: { $ref: '#/components/schemas/Inspection' },
                            description: 'Inspections successfully synchronized',
                            example: [
                                { id: 1, title: 'Inspeção 1', status: 'pending', userId: 1, createdAt: '2024-07-15T12:00:00Z', updatedAt: '2024-07-15T12:00:00Z' }
                            ]
                        },
                        syncedPhotos: {
                            type: 'array',
                            items: { $ref: '#/components/schemas/Photo' },
                            description: 'Photos successfully synchronized',
                            example: [
                                { id: 1, url: 'https://site.com/foto1.jpg', inspectionId: 1, createdAt: '2024-07-15T12:00:00Z' }
                            ]
                        },
                        conflicts: {
                            type: 'array',
                            items: {
                                type: 'object',
                                properties: {
                                    type: { type: 'string', description: 'Type of record (user, inspection, photo)' },
                                    data: { type: 'object', description: 'Original data that caused conflict' },
                                    error: { type: 'string', description: 'Error message' },
                                },
                            },
                            description: 'Detalhes de conflitos encontrados durante a sincronização',
                            example: [
                                { type: 'user', data: { email: 'duplicado@email.com' }, error: 'User with this email already exists' }
                            ]
                        },
                    },
                    description: 'Retorno da sincronização, com arrays dos registros sincronizados e conflitos.',
                    example: {
                        syncedUsers: [
                            { id: 1, email: 'user1@email.com', name: 'User 1', role: 'USER', createdAt: '2024-07-15T12:00:00Z' }
                        ],
                        syncedInspections: [
                            { id: 1, title: 'Inspeção 1', status: 'pending', userId: 1, createdAt: '2024-07-15T12:00:00Z', updatedAt: '2024-07-15T12:00:00Z' }
                        ],
                        syncedPhotos: [
                            { id: 1, url: 'https://site.com/foto1.jpg', inspectionId: 1, createdAt: '2024-07-15T12:00:00Z' }
                        ],
                        conflicts: [
                            { type: 'user', data: { email: 'duplicado@email.com' }, error: 'User with this email already exists' }
                        ]
                    }
                },
            },
        },
        security: [{
                bearerAuth: [],
            }],
    },
    apis: ['./src/routes/*.ts', './src/controllers/*.ts'],
};
const swaggerSpec = (0, swagger_jsdoc_1.default)(swaggerOptions);
app_1.default.use('/api-docs', swagger_ui_express_1.default.serve, swagger_ui_express_1.default.setup(swaggerSpec));
// Rota para servir o JSON cru do OpenAPI
app_1.default.get('/swagger.json', (req, res) => {
    res.setHeader('Content-Type', 'application/json');
    res.send(swaggerSpec);
});
// Server Start
app_1.default.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
    console.log(`Swagger docs available at http://localhost:${PORT}/api-docs`);
    console.log(`Swagger JSON available at http://localhost:${PORT}/swagger.json`);
});
