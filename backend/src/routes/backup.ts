import express from 'express';
import { AuthRequest } from '../middleware/auth';
import { BackupService } from '../services/backup';

const router = express.Router();
const backupService = new BackupService();

// Create backup
router.post('/create', async (req: AuthRequest, res) => {
  try {
    const { workspaceId, provider, options } = req.body;

    const backup = await backupService.createBackup(
      workspaceId,
      req.user!.id,
      provider,
      options
    );

    res.status(201).json(backup);
  } catch (error) {
    console.error('Create backup error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// List backups
router.get('/list/:workspaceId', async (req: AuthRequest, res) => {
  try {
    const { workspaceId } = req.params;

    const backups = await backupService.listBackups(workspaceId, req.user!.id);

    res.json(backups);
  } catch (error) {
    console.error('List backups error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Restore backup
router.post('/restore', async (req: AuthRequest, res) => {
  try {
    const { backupId, workspaceId } = req.body;

    await backupService.restoreBackup(backupId, workspaceId, req.user!.id);

    res.json({ message: 'Backup restored successfully' });
  } catch (error) {
    console.error('Restore backup error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Configure backup settings
router.post('/configure', async (req: AuthRequest, res) => {
  try {
    const { workspaceId, settings } = req.body;

    await backupService.configureBackup(workspaceId, req.user!.id, settings);

    res.json({ message: 'Backup configured successfully' });
  } catch (error) {
    console.error('Configure backup error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;
