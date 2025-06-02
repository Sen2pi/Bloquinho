'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { usePageStore } from '@/lib/stores/page'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { FileText, ExternalLink } from 'lucide-react'
import toast from 'react-hot-toast'

interface PageBlockProps {
  content: { title?: string; pageId?: string }
  onChange: (content: { title?: string; pageId?: string }) => void
  parentPageId: string
}

export function PageBlock({ content, onChange, parentPageId }: PageBlockProps) {
  const router = useRouter()
  const { createPage } = usePageStore()
  const [title, setTitle] = useState(content.title || 'Untitled Page')
  const [isCreating, setIsCreating] = useState(!content.pageId)

  const handleCreatePage = async () => {
    if (!title.trim()) {
      toast.error('Page title is required')
      return
    }

    setIsCreating(true)
    try {
      // Get parent page to get workspace ID
      const parentPage = await fetch(`/api/pages/${parentPageId}`).then(res => res.json())
      
      const newPage = await createPage({
        title: title.trim(),
        workspaceId: parentPage.workspaceId,
        parentId: parentPageId,
        icon: '📄'
      })

      onChange({ title: title.trim(), pageId: newPage.id })
      toast.success('Sub-page created!')
    } catch (error) {
      console.error('Failed to create page:', error)
      toast.error('Failed to create sub-page')
    } finally {
      setIsCreating(false)
    }
  }

  const handleOpenPage = () => {
    if (content.pageId) {
      router.push(`/page/${content.pageId}`)
    }
  }

  if (content.pageId) {
    // Page already created - show link
    return (
      <div className="border rounded-lg p-4 bg-gray-50 hover:bg-gray-100 transition-colors">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-3">
            <FileText className="h-5 w-5 text-blue-600" />
            <span className="font-medium">{content.title}</span>
          </div>
          <Button
            variant="ghost"
            size="sm"
            onClick={handleOpenPage}
            className="text-blue-600 hover:text-blue-700"
          >
            <ExternalLink className="h-4 w-4" />
          </Button>
        </div>
      </div>
    )
  }

  // Page not created yet - show creation form
  return (
    <div className="border-2 border-dashed border-gray-300 rounded-lg p-4">
      <div className="flex items-center space-x-3">
        <FileText className="h-5 w-5 text-gray-400" />
        <Input
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          placeholder="Enter page title..."
          className="flex-1"
          onKeyDown={(e) => e.key === 'Enter' && handleCreatePage()}
        />
        <Button
          onClick={handleCreatePage}
          disabled={isCreating || !title.trim()}
          size="sm"
        >
          {isCreating ? 'Creating...' : 'Create Page'}
        </Button>
      </div>
      <p className="text-xs text-gray-500 mt-2">
        This will create a new page inside the current page
      </p>
    </div>
  )
}
