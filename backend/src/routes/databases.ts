import express from 'express';
import { prisma } from '../server';
import { AuthRequest } from '../middleware/auth';

const router = express.Router();

// Create database
router.post('/', async (req: AuthRequest, res) => {
  try {
    const { name, description, properties } = req.body;

    const database = await prisma.database.create({
      data: {
        name,
        description,
        properties
      }
    });

    res.status(201).json(database);
  } catch (error) {
    console.error('Create database error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Get database
router.get('/:id', async (req: AuthRequest, res) => {
  try {
    const { id } = req.params;

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

    res.json(database);
  } catch (error) {
    console.error('Get database error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;
