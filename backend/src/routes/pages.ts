import express from 'express';
import { prisma } from '../server';
import { AuthRequest } from '../middleware/auth';

const router = express.Router();

// Get all pages in workspace
router.get('/workspace/:workspaceId', async (req: AuthRequest, res) => {
  try {
    const { workspaceId } = req.params;

    // Check if user has access to workspace
    const member = await prisma.workspaceMember.findUnique({
      where: {
        userId_workspaceId: {
          userId: req.user!.id,
          workspaceId
        }
      }
    });

    if (!member) {
      return res.status(403).json({ error: 'Access denied' });
    }

    const pages = await prisma.page.findMany({
      where: { workspaceId },
      include: {
        creator: {
          select: { id: true, name: true, email: true }
        },
        children: true
      },
      orderBy: { createdAt: 'desc' }
    });

    res.json(pages);
  } catch (error) {
    console.error('Get pages error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get page by ID
router.get('/:id', async (req: AuthRequest, res) => {
  try {
    const { id } = req.params;

    const page = await prisma.page.findUnique({
      where: { id },
      include: {
        creator: {
          select: { id: true, name: true, email: true }
        },
        blocks: {
          orderBy: { order: 'asc' },
          include: {
            creator: {
              select: { id: true, name: true }
            }
          }
        },
        children: true,
        workspace: {
          include: {
            members: {
              where: { userId: req.user!.id }
            }
          }
        }
      }
    });

    if (!page) {
      return res.status(404).json({ error: 'Page not found' });
    }

    // Check access
    if (page.workspace.members.length === 0) {
      return res.status(403).json({ error: 'Access denied' });
    }

    res.json(page);
  } catch (error) {
    console.error('Get page error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Create page
router.post('/', async (req: AuthRequest, res) => {
  try {
    const { title, workspaceId, parentId, icon, cover } = req.body;

    // Check workspace access
    const member = await prisma.workspaceMember.findUnique({
      where: {
        userId_workspaceId: {
          userId: req.user!.id,
          workspaceId
        }
      }
    });

    if (!member) {
      return res.status(403).json({ error: 'Access denied' });
    }

    const page = await prisma.page.create({
      data: {
        title: title || 'Untitled',
        workspaceId,
        parentId,
        icon,
        cover,
        createdBy: req.user!.id
      },
      include: {
        creator: {
          select: { id: true, name: true, email: true }
        }
      }
    });

    res.status(201).json(page);
  } catch (error) {
    console.error('Create page error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update page
router.put('/:id', async (req: AuthRequest, res) => {
  try {
    const { id } = req.params;
    const { title, icon, cover } = req.body;

    // Check if page exists and user has access
    const page = await prisma.page.findUnique({
      where: { id },
      include: {
        workspace: {
          include: {
            members: {
              where: { userId: req.user!.id }
            }
          }
        }
      }
    });

    if (!page || page.workspace.members.length === 0) {
      return res.status(404).json({ error: 'Page not found' });
    }

    const updatedPage = await prisma.page.update({
      where: { id },
      data: { title, icon, cover },
      include: {
        creator: {
          select: { id: true, name: true, email: true }
        }
      }
    });

    res.json(updatedPage);
  } catch (error) {
    console.error('Update page error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Delete page
router.delete('/:id', async (req: AuthRequest, res) => {
  try {
    const { id } = req.params;

    // Check if page exists and user has access
    const page = await prisma.page.findUnique({
      where: { id },
      include: {
        workspace: {
          include: {
            members: {
              where: { userId: req.user!.id }
            }
          }
        }
      }
    });

    if (!page || page.workspace.members.length === 0) {
      return res.status(404).json({ error: 'Page not found' });
    }

    await prisma.page.delete({
      where: { id }
    });

    res.json({ message: 'Page deleted successfully' });
  } catch (error) {
    console.error('Delete page error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;
