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

// Update workspace
router.put('/:id', async (req: AuthRequest, res) => {
  try {
    const { id } = req.params;
    const { name, description, icon } = req.body;

    // Check if user is owner or admin
    const member = await prisma.workspaceMember.findUnique({
      where: {
        userId_workspaceId: {
          userId: req.user!.id,
          workspaceId: id
        }
      }
    });

    if (!member || (member.role !== 'OWNER' && member.role !== 'ADMIN')) {
      return res.status(403).json({ error: 'Access denied' });
    }

    const workspace = await prisma.workspace.update({
      where: { id },
      data: { name, description, icon },
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

    res.json(workspace);
  } catch (error) {
    console.error('Update workspace error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Invite user to workspace
router.post('/:id/invite', async (req: AuthRequest, res) => {
  try {
    const { id } = req.params;
    const { email, role = 'MEMBER' } = req.body;

    // Check if user is owner or admin
    const member = await prisma.workspaceMember.findUnique({
      where: {
        userId_workspaceId: {
          userId: req.user!.id,
          workspaceId: id
        }
      }
    });

    if (!member || (member.role !== 'OWNER' && member.role !== 'ADMIN')) {
      return res.status(403).json({ error: 'Access denied' });
    }

    // Find user by email
    const user = await prisma.user.findUnique({
      where: { email }
    });

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Check if user is already a member
    const existingMember = await prisma.workspaceMember.findUnique({
      where: {
        userId_workspaceId: {
          userId: user.id,
          workspaceId: id
        }
      }
    });

    if (existingMember) {
      return res.status(400).json({ error: 'User is already a member' });
    }

    // Add user to workspace
    const newMember = await prisma.workspaceMember.create({
      data: {
        userId: user.id,
        workspaceId: id,
        role
      },
      include: {
        user: {
          select: { id: true, name: true, email: true, avatar: true }
        }
      }
    });

    res.status(201).json(newMember);
  } catch (error) {
    console.error('Invite user error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;
