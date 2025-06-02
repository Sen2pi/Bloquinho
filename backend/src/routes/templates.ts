import express from 'express';
import { prisma } from '../server';
import { AuthRequest } from '../middleware/auth';

const router = express.Router();

// Get templates
router.get('/', async (req: AuthRequest, res) => {
  try {
    const templates = [
      {
        id: 'meeting-notes',
        name: 'Meeting Notes',
        description: 'Template for meeting notes with agenda and action items',
        category: 'productivity',
        blocks: [
          {
            type: 'HEADING_1',
            content: { text: 'Meeting Notes' }
          },
          {
            type: 'TEXT',
            content: { text: 'Date: ' }
          },
          {
            type: 'TEXT',
            content: { text: 'Attendees: ' }
          },
          {
            type: 'HEADING_2',
            content: { text: 'Agenda' }
          },
          {
            type: 'BULLET_LIST',
            content: { items: ['Item 1', 'Item 2', 'Item 3'] }
          },
          {
            type: 'HEADING_2',
            content: { text: 'Action Items' }
          },
          {
            type: 'TODO',
            content: { text: 'Action item 1', checked: false }
          }
        ]
      },
      {
        id: 'project-plan',
        name: 'Project Plan',
        description: 'Template for project planning with timeline and tasks',
        category: 'project-management',
        blocks: [
          {
            type: 'HEADING_1',
            content: { text: 'Project Plan' }
          },
          {
            type: 'HEADING_2',
            content: { text: 'Overview' }
          },
          {
            type: 'TEXT',
            content: { text: 'Project description...' }
          },
          {
            type: 'HEADING_2',
            content: { text: 'Timeline' }
          },
          {
            type: 'DATABASE',
            content: {
              properties: {
                'Task': { type: 'title' },
                'Status': { type: 'select', options: ['Not Started', 'In Progress', 'Completed'] },
                'Assignee': { type: 'person' },
                'Due Date': { type: 'date' }
              }
            }
          }
        ]
      },
      {
        id: 'daily-journal',
        name: 'Daily Journal',
        description: 'Template for daily journaling and reflection',
        category: 'personal',
        blocks: [
          {
            type: 'HEADING_1',
            content: { text: new Date().toLocaleDateString() }
          },
          {
            type: 'HEADING_2',
            content: { text: 'Today\'s Goals' }
          },
          {
            type: 'TODO',
            content: { text: 'Goal 1', checked: false }
          },
          {
            type: 'TODO',
            content: { text: 'Goal 2', checked: false }
          },
          {
            type: 'HEADING_2',
            content: { text: 'Reflection' }
          },
          {
            type: 'TEXT',
            content: { text: 'How did today go?' }
          }
        ]
      }
    ];

    res.json(templates);
  } catch (error) {
    console.error('Get templates error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Apply template to page
router.post('/apply', async (req: AuthRequest, res) => {
  try {
    const { templateId, pageId } = req.body;

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

    // Get template (this would be from database in production)
    const templates = await this.getTemplates();
    const template = templates.find(t => t.id === templateId);

    if (!template) {
      return res.status(404).json({ error: 'Template not found' });
    }

    // Create blocks from template
    const blocks = await Promise.all(
      template.blocks.map((block, index) =>
        prisma.block.create({
          data: {
            type: block.type as any,
            content: block.content,
            pageId,
            order: index,
            createdBy: req.user!.id
          }
        })
      )
    );

    res.json(blocks);
  } catch (error) {
    console.error('Apply template error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }

  private async getTemplates() {
    // This would fetch from database in production
    return []; // Return templates array
  }
});

export default router;
