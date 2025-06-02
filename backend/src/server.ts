import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { createServer } from 'http';
import { Server } from 'socket.io';
import { PrismaClient } from '@prisma/client';
import { createClient } from 'redis';

import authRoutes from './routes/auth';
import workspaceRoutes from './routes/workspaces';
import pageRoutes from './routes/pages';
import blockRoutes from './routes/blocks';
import databaseRoutes from './routes/databases';
import backupRoutes from './routes/backup';

import { authMiddleware } from './middleware/auth';
import { setupCollaboration } from './services/collaboration';

const app = express();
const server = createServer(app);
const io = new Server(server, {
  cors: {
    origin: process.env.FRONTEND_URL || "http://localhost:3000",
    methods: ["GET", "POST"]
  }
});

// Database
export const prisma = new PrismaClient();

// Redis
export const redis = createClient({
  url: process.env.REDIS_URL || 'redis://localhost:6379'
});

// Middleware
app.use(helmet());
app.use(cors());
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
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Setup real-time collaboration
setupCollaboration(io);

const PORT = process.env.PORT || 3001;

async function startServer() {
  try {
    await redis.connect();
    console.log('Connected to Redis');
    
    await prisma.$connect();
    console.log('Connected to PostgreSQL');
    
    server.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);
    });
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
}

startServer();

// Graceful shutdown
process.on('SIGTERM', async () => {
  await prisma.$disconnect();
  await redis.disconnect();
  process.exit(0);
});
