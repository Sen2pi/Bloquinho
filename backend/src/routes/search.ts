import express from 'express';
import { prisma } from '../server';
import { AuthRequest } from '../middleware/auth';

const router = express.Router();

// Global search
router.get('/', async (req: AuthRequest, res) => {
  try {
    const { q, workspaceId, type } = req.query;

    if (!q || typeof q !== 'string') {
      return res.status(400).json({ error: 'Search query is required' });
    }

    const searchTerm = q.toLowerCase();

    // Search pages
    const pages = await prisma.page.findMany({
      where: {
        AND: [
          workspaceId ? { workspaceId: workspaceId as string } : {},
          {
            workspace: {
              members: {
                some: { userId: req.user!.id }
              }
            }
          },
          {
            OR: [
              { title: { contains: searchTerm, mode: 'insensitive' } }
            ]
          }
        ]
      },
      include: {
        creator: {
          select: { id: true, name: true }
        },
        workspace: {
          select: { id: true, name: true }
        }
      },
      take: type === 'pages' ? 50 : 10
    });

    // Search blocks
    const blocks = await prisma.block.findMany({
      where: {
        AND: [
          {
            page: {
              workspace: {
                members: {
                  some: { userId: req.user!.id }
                }
              }
            }
          },
          workspaceId ? {
            page: { workspaceId: workspaceId as string }
          } : {}
        ]
      },
      include: {
        page: {
          select: { id: true, title: true, workspaceId: true }
        },
        creator: {
          select: { id: true, name: true }
        }
      },
      take: type === 'blocks' ? 50 : 10
    });

    // Filter blocks by content
    const filteredBlocks = blocks.filter(block => {
      const content = JSON.stringify(block.content).toLowerCase();
      return content.includes(searchTerm);
    });

    const results = {
      pages: type === 'blocks' ? [] : pages,
      blocks: type === 'pages' ? [] : filteredBlocks,
      total: (type === 'blocks' ? 0 : pages.length) + (type === 'pages' ? 0 : filteredBlocks.length)
    };

    res.json(results);
  } catch (error) {
    console.error('Search error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;
