import express from 'express';
import { prisma } from '../server';
import { AuthRequest } from '../middleware/auth';

const router = express.Router();

// Create block
router.post('/', async (req: AuthRequest, res) => {
  try {
    const { type, content, pageId, parentId, order } = req.body;

    // Check page access
    const page = await prisma.page.findUnique({
      where: { id: pageId },
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
      return res.status(403).json({ error: 'Access denied' });
    }

    const block = await prisma.block.create({
      data: {
        type,
        content,
        pageId,
        parentId,
        order: order || 0,
        createdBy: req.user!.id
      },
      include: {
        creator: {
          select: { id: true, name: true }
        }
      }
    });

    res.status(201).json(block);
  } catch (error) {
    console.error('Create block error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update block
router.put('/:id', async (req: AuthRequest, res) => {
  try {
    const { id } = req.params;
    const { content, type } = req.body;

    // Check block access
    const block = await prisma.block.findUnique({
      where: { id },
      include: {
        page: {
          include: {
            workspace: {
              include: {
                members: {
                  where: { userId: req.user!.id }
                }
              }
            }
          }
        }
      }
    });

    if (!block || block.page.workspace.members.length === 0) {
      return res.status(404).json({ error: 'Block not found' });
    }

    const updatedBlock = await prisma.block.update({
      where: { id },
      data: { content, type },
      include: {
        creator: {
          select: { id: true, name: true }
        }
      }
    });

    res.json(updatedBlock);
  } catch (error) {
    console.error('Update block error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Delete block
router.delete('/:id', async (req: AuthRequest, res) => {
  try {
    const { id } = req.params;

    // Check block access
    const block = await prisma.block.findUnique({
      where: { id },
      include: {
        page: {
          include: {
            workspace: {
              include: {
                members: {
                  where: { userId: req.user!.id }
                }
              }
            }
          }
        }
      }
    });

    if (!block || block.page.workspace.members.length === 0) {
      return res.status(404).json({ error: 'Block not found' });
    }

    await prisma.block.delete({
      where: { id }
    });

    res.json({ message: 'Block deleted successfully' });
  } catch (error) {
    console.error('Delete block error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Reorder blocks
router.put('/reorder', async (req: AuthRequest, res) => {
  try {
    const { blocks } = req.body; // Array of { id, order }

    // Update all blocks in a transaction
    await prisma.$transaction(
      blocks.map((block: { id: string; order: number }) =>
        prisma.block.update({
          where: { id: block.id },
          data: { order: block.order }
        })
      )
    );

    res.json({ message: 'Blocks reordered successfully' });
  } catch (error) {
    console.error('Reorder blocks error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;
