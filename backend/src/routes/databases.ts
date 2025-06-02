import express from 'express';
import { prisma } from '../server';
import { AuthRequest } from '../middleware/auth';

const router = express.Router();

// Create database
router.post('/', async (req: AuthRequest, res) => {
  try {
    const { name, description, properties, pageId } = req.body;

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

    const database = await prisma.database.create({
      data: {
        name,
        description,
        properties
      }
    });

    // Create database block
    await prisma.block.create({
      data: {
        type: 'DATABASE',
        content: { databaseId: database.id },
        pageId,
        order: 0,
        createdBy: req.user!.id
      }
    });

    res.status(201).json(database);
  } catch (error) {
    console.error('Create database error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get database with rows
router.get('/:id', async (req: AuthRequest, res) => {
  try {
    const { id } = req.params;
    const { view = 'table', filter, sort } = req.query;

    const database = await prisma.database.findUnique({
      where: { id },
      include: {
        rows: {
          orderBy: { createdAt: 'desc' }
        }
      }
    });

    if (!database) {
      return res.status(404).json({ error: 'Database not found' });
    }

    // Apply filters and sorting if provided
    let rows = database.rows;

    if (filter) {
      // Implement filtering logic based on filter parameter
    }

    if (sort) {
      // Implement sorting logic based on sort parameter
    }

    res.json({ ...database, rows });
  } catch (error) {
    console.error('Get database error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update database properties
router.put('/:id', async (req: AuthRequest, res) => {
  try {
    const { id } = req.params;
    const { name, description, properties } = req.body;

    const database = await prisma.database.update({
      where: { id },
      data: { name, description, properties }
    });

    res.json(database);
  } catch (error) {
    console.error('Update database error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Create database row
router.post('/:id/rows', async (req: AuthRequest, res) => {
  try {
    const { id } = req.params;
    const { data } = req.body;

    const row = await prisma.databaseRow.create({
      data: {
        databaseId: id,
        data
      }
    });

    res.status(201).json(row);
  } catch (error) {
    console.error('Create row error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Update database row
router.put('/:id/rows/:rowId', async (req: AuthRequest, res) => {
  try {
    const { rowId } = req.params;
    const { data } = req.body;

    const row = await prisma.databaseRow.update({
      where: { id: rowId },
      data: { data }
    });

    res.json(row);
  } catch (error) {
    console.error('Update row error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Delete database row
router.delete('/:id/rows/:rowId', async (req: AuthRequest, res) => {
  try {
    const { rowId } = req.params;

    await prisma.databaseRow.delete({
      where: { id: rowId }
    });

    res.json({ message: 'Row deleted successfully' });
  } catch (error) {
    console.error('Delete row error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;
