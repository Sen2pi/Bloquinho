import { Server } from 'socket.io';
import jwt from 'jsonwebtoken';
import { prisma } from '../server';

export function setupCollaboration(io: Server) {
  // Authentication middleware for socket connections
  io.use(async (socket, next) => {
    try {
      const token = socket.handshake.auth.token;
      
      if (!token) {
        return next(new Error('Authentication error'));
      }

      const decoded = jwt.verify(token, process.env.JWT_SECRET!) as any;
      
      const user = await prisma.user.findUnique({
        where: { id: decoded.userId },
        select: { id: true, email: true, name: true }
      });

      if (!user) {
        return next(new Error('Authentication error'));
      }

      socket.data.user = user;
      next();
    } catch (error) {
      next(new Error('Authentication error'));
    }
  });

  io.on('connection', (socket) => {
    console.log(`User ${socket.data.user.name} connected`);

    // Join page room for real-time collaboration
    socket.on('join-page', (pageId: string) => {
      socket.join(`page:${pageId}`);
      socket.to(`page:${pageId}`).emit('user-joined', {
        userId: socket.data.user.id,
        userName: socket.data.user.name
      });
    });

    // Leave page room
    socket.on('leave-page', (pageId: string) => {
      socket.leave(`page:${pageId}`);
      socket.to(`page:${pageId}`).emit('user-left', {
        userId: socket.data.user.id,
        userName: socket.data.user.name
      });
    });

    // Handle block updates
    socket.on('block-update', (data: {
      pageId: string;
      blockId: string;
      content: any;
      type: string;
    }) => {
      socket.to(`page:${data.pageId}`).emit('block-updated', {
        ...data,
        updatedBy: socket.data.user.id
      });
    });

    // Handle cursor position
    socket.on('cursor-position', (data: {
      pageId: string;
      blockId: string;
      position: number;
    }) => {
      socket.to(`page:${data.pageId}`).emit('cursor-moved', {
        ...data,
        userId: socket.data.user.id,
        userName: socket.data.user.name
      });
    });

    // Handle comments
    socket.on('new-comment', (data: {
      pageId: string;
      content: string;
    }) => {
      socket.to(`page:${data.pageId}`).emit('comment-added', {
        ...data,
        author: socket.data.user
      });
    });

    socket.on('disconnect', () => {
      console.log(`User ${socket.data.user.name} disconnected`);
    });
  });
}
