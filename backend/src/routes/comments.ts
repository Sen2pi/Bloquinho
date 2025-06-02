import express from 'express';
import { prisma } from '../server';
import { AuthRequest } from '../middleware/auth';

const router = express.Router();

// Get comments for a page
router.get('/page/:pageId', async (req: AuthRequest, res) => {
  try {
    const { pageId } = req.params;

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

    const comments = await prisma.comment.findMany({
      where: { pageId },
      include: {
        creator: {
          select: { id: true, name: true, email: true, avatar: true }
        }
      },
      orderBy: { createdAt: 'desc' }
    });

    res.json(comments);
  } catch (error) {
    console.error('Get comments error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Create comment
router.post('/', async (req: AuthRequest, res) => {
  try {
    const { content, pageId } = req.body;

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

    const comment = await prisma.comment.create({
      data: {
        content,
        pageId,
        createdBy: req.user!.id
      },
      include: {
        creator: {
          select: { id: true, name: true, email: true, avatar: true }
        }
      }
    });

    res.status(201).json(comment);
  } catch (error) {
    console.error('Create comment error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update comment
router.put('/:id', async (req: AuthRequest, res) => {
  try {
    const { id } = req.params;
    const { content } = req.body;

    // Check if user owns the comment
    const comment = await prisma.comment.findUnique({
      where: { id }
    });

    if (!comment || comment.createdBy !== req.user!.id) {
      return res.status(403).json({ error: 'Access denied' });
    }

    const updatedComment = await prisma.comment.update({
      where: { id },
      data: { content },
      include: {
        creator: {
          select: { id: true, name: true, email: true, avatar: true }
        }
      }
    });

    res.json(updatedComment);
  } catch (error) {
    console.error('Update comment error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Delete comment
router.delete('/:id', async (req: AuthRequest, res) => {
  try {
    const { id } = req.params;

    // Check if user owns the comment
    const comment = await prisma.comment.findUnique({
      where: { id }
    });

    if (!comment || comment.createdBy !== req.user!.id) {
      return res.status(403).json({ error: 'Access denied' });
    }

    await prisma.comment.delete({
      where: { id }
    });

    res.json({ message: 'Comment deleted successfully' });
  } catch (error) {
    console.error('Delete comment error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;
