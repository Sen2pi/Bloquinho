import express from 'express';
import { prisma } from '../server';
import { AuthRequest } from '../middleware/auth';

const router = express.Router();

// Get user workspaces
router.get('/', async (req: AuthRequest, res) => {
  try {
    const workspaces = await prisma.workspace.findMany({
      where: {
        members: {
          some: {
            userId: req.user!.id
          }
        }
      },
      include: {
        members: {
          include: {
            user: {
              select: { id: true, name: true, email: true, avatar: true }
            }
          }
        },
        _count: {
          select: { pages: true }
        }
      }
    });

    res.json(workspaces);
  } catch (error) {
    console.error('Get workspaces error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Create workspace
router.post('/', async (req: AuthRequest, res) => {
  try {
    const { name, description, icon } = req.body;

    const workspace = await prisma.workspace.create({
      data: {
        name,
        description,
        icon,
        members: {
          create: {
            userId: req.user!.id,
            role: 'OWNER'
          }
        }
      },
      include: {
        members: {
          include: {
            user: {
              select: { id: true, name: true, email: true, avatar: true }
            }
          }
        }
      }
    });

    res.status(201).json(workspace);
  } catch (error) {
    console.error('Create workspace error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;
