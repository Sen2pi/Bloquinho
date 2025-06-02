import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { PrismaClient } from '@prisma/client';

import authRoutes from './routes/auth';
import workspaceRoutes from './routes/workspaces';
import pageRoutes from './routes/pages';
import blockRoutes from './routes/blocks';
import databaseRoutes from './routes/databases';
import backupRoutes from './routes/backup';

import { authMiddleware } from './middleware/auth';

const app = express();

// Database
export const prisma = new PrismaClient();

// Middleware
app.use(helmet());
app.use(cors({
  origin: process.env.FRONTEND_URL || "http://localhost:3000",
  credentials: true
}));
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/workspaces', authMiddleware, workspaceRoutes);
app.use('/api/pages', authMiddleware, pageRoutes);
app.use('/api/blocks', authMiddleware, blockRoutes);
app.use('/api/databases', authMiddleware, databaseRoutes);
app.use('/api/backup', authMiddleware, backupRoutes);

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    timestamp: new Date().toISOString(),
    database: 'connected'
  });
});

const PORT = process.env.PORT || 3001;

async function startServer() {
  try {
    // Conectar Prisma
    await prisma.$connect();
    console.log('✅ Connected to PostgreSQL');
    
    // Iniciar servidor
    app.listen(PORT, () => {
      console.log(`🚀 Server running on port ${PORT}`);
      console.log(`📊 Health check: http://localhost:${PORT}/health`);
    });
  } catch (error) {
    console.error('❌ Failed to start server:', error);
    process.exit(1);
  }
}

startServer();

// Graceful shutdown
process.on('SIGTERM', async () => {
  console.log('🛑 Shutting down gracefully...');
  await prisma.$disconnect();
  process.exit(0);
});

process.on('SIGINT', async () => {
  console.log('🛑 Shutting down gracefully...');
  await prisma.$disconnect();
  process.exit(0);
});
