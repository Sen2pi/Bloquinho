'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { usePageStore } from '@/lib/stores/page'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import { FileText, Sparkles } from 'lucide-react'
import toast from 'react-hot-toast'

interface CreatePageDialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  workspaceId?: string
  parentId?: string
}

const pageIcons = ['📄', '📝', '📋', '📊', '📈', '🎯', '💡', '🚀', '📚', '🔥']

export function CreatePageDialog({ 
  open, 
  onOpenChange, 
  workspaceId,
  parentId 
}: CreatePageDialogProps) {
  const router = useRouter()
  const { createPage } = usePageStore()
  
  const [isLoading, setIsLoading] = useState(false)
  const [formData, setFormData] = useState({
    title: '',
    icon: '📄',
    description: ''
  })

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    
    if (!workspaceId) {
      toast.error('No workspace selected')
      return
    }

    if (!formData.title.trim()) {
      toast.error('Page title is required')
      return
    }

    setIsLoading(true)

    try {
      const page = await createPage({
        title: formData.title.trim(),
        workspaceId,
        parentId,
        icon: formData.icon
      })

      toast.success('Page created successfully! 🎉', {
        style: {
          background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
          color: 'white',
        },
      })

      onOpenChange(false)
      setFormData({ title: '', icon: '📄', description: '' })
      
      // Navigate to the new page
      router.push(`/page/${page.id}`)
    } catch (error: any) {
      toast.error(error.message || 'Failed to create page')
    } finally {
      setIsLoading(false)
    }
  }

  const handleClose = () => {
    onOpenChange(false)
    setFormData({ title: '', icon: '📄', description: '' })
  }

  return (
    <Dialog open={open} onOpenChange={handleClose}>
      <DialogContent className="sm:max-w-[425px]">
        <DialogHeader>
          <div className="flex items-center space-x-2">
            <Sparkles className="h-5 w-5 text-purple-600" />
            <DialogTitle>Create New Page</DialogTitle>
          </div>
          <DialogDescription>
            Create a new page to start organizing your thoughts and ideas.
          </DialogDescription>
        </DialogHeader>
        
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="title">Page Title</Label>
            <Input
              id="title"
              placeholder="Enter page title..."
              value={formData.title}
              onChange={(e) => setFormData({ ...formData, title: e.target.value })}
              className="h-12"
              required
            />
          </div>

          <div className="space-y-2">
            <Label>Choose an Icon</Label>
            <div className="grid grid-cols-5 gap-2">
              {pageIcons.map((icon) => (
                <Button
                  key={icon}
                  type="button"
                  variant={formData.icon === icon ? "default" : "outline"}
                  className="h-12 text-lg"
                  onClick={() => setFormData({ ...formData, icon })}
                >
                  {icon}
                </Button>
              ))}
            </div>
          </div>

          <DialogFooter>
            <Button
              type="button"
              variant="outline"
              onClick={handleClose}
              disabled={isLoading}
            >
              Cancel
            </Button>
            <Button 
              type="submit" 
              disabled={isLoading || !formData.title.trim()}
              className="bg-gradient-to-r from-purple-600 to-pink-600 hover:from-purple-700 hover:to-pink-700"
            >
              {isLoading ? (
                <div className="flex items-center space-x-2">
                  <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                  <span>Creating...</span>
                </div>
              ) : (
                <>
                  <FileText className="h-4 w-4 mr-2" />
                  Create Page
                </>
              )}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  )
}
