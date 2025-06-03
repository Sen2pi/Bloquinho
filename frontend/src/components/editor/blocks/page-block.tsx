'use client'

import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { usePageStore } from '@/lib/stores/page'
import { useWorkspaceStore } from '@/lib/stores/workspace'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { FileText, ExternalLink, Edit3, Trash2, Plus } from 'lucide-react'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import toast from 'react-hot-toast'

interface PageBlockProps {
  content: { title?: string; pageId?: string }
  onChange: (content: { title?: string; pageId?: string }) => void
  parentPageId?: string
}

const pageIcons = ['📄', '📝', '📋', '📊', '📈', '🎯', '💡', '🚀', '📚', '🔥', '⚡', '🌟']

export function PageBlock({ content, onChange, parentPageId }: PageBlockProps) {
  const router = useRouter()
  const { createPage, deletePage } = usePageStore()
  const { currentWorkspace } = useWorkspaceStore()
  
  const [title, setTitle] = useState(content.title || 'Untitled Page')
  const [selectedIcon, setSelectedIcon] = useState('📄')
  const [isCreating, setIsCreating] = useState(!content.pageId)
  const [isEditing, setIsEditing] = useState(false)

  useEffect(() => {
    if (content.title) setTitle(content.title)
  }, [content.title])

  const handleCreatePage = async () => {
    if (!title.trim()) {
      toast.error('Page title is required')
      return
    }

    if (!currentWorkspace) {
      toast.error('No workspace selected')
      return
    }

    setIsCreating(true)
    try {
      const newPage = await createPage({
        title: title.trim(),
        workspaceId: currentWorkspace.id,
        parentId: parentPageId || null,
        icon: selectedIcon
      })

      onChange({ 
        title: title.trim(), 
        pageId: newPage.id 
      })
      
      toast.success('Sub-page created successfully! 🎉')
      setIsCreating(false)
    } catch (error: any) {
      console.error('Failed to create page:', error)
      toast.error(error.message || 'Failed to create sub-page')
      setIsCreating(false)
    }
  }

  const handleOpenPage = () => {
    if (content.pageId) {
      router.push(`/page/${content.pageId}`)
    }
  }

  const handleEditTitle = async () => {
    if (!content.pageId || !title.trim()) return

    try {
      // Update page title via API
      await fetch(`/api/pages/${content.pageId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ title: title.trim() })
      })

      onChange({ 
        title: title.trim(), 
        pageId: content.pageId 
      })
      
      setIsEditing(false)
      toast.success('Page title updated!')
    } catch (error) {
      console.error('Failed to update page title:', error)
      toast.error('Failed to update page title')
    }
  }

  const handleDeletePage = async () => {
    if (!content.pageId) return

    if (confirm('Are you sure you want to delete this sub-page? This action cannot be undone.')) {
      try {
        await deletePage(content.pageId)
        onChange({ title: '', pageId: '' })
        toast.success('Sub-page deleted!')
      } catch (error) {
        console.error('Failed to delete page:', error)
        toast.error('Failed to delete sub-page')
      }
    }
  }

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter') {
      if (isCreating) {
        handleCreatePage()
      } else if (isEditing) {
        handleEditTitle()
      }
    } else if (e.key === 'Escape') {
      setIsEditing(false)
      setTitle(content.title || 'Untitled Page')
    }
  }

  if (content.pageId && !isEditing) {
    // Página já criada - mostrar link
    return (
      <div className="group border rounded-lg p-4 bg-gradient-to-r from-blue-50 to-indigo-50 hover:from-blue-100 hover:to-indigo-100 transition-all duration-200">
        <div className="flex items-center justify-between">
          <div 
            className="flex items-center space-x-3 flex-1 cursor-pointer"
            onClick={handleOpenPage}
          >
            <div className="text-2xl">{selectedIcon}</div>
            <div className="flex-1">
              <h3 className="font-medium text-gray-900 text-lg">{content.title}</h3>
              <p className="text-sm text-gray-500">Click to open sub-page</p>
            </div>
          </div>
          
          <div className="flex items-center space-x-2 opacity-0 group-hover:opacity-100 transition-opacity">
            <Button
              variant="ghost"
              size="sm"
              onClick={handleOpenPage}
              className="text-blue-600 hover:text-blue-700"
            >
              <ExternalLink className="h-4 w-4" />
            </Button>
            
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button variant="ghost" size="sm">
                  <Edit3 className="h-4 w-4" />
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent>
                <DropdownMenuItem onClick={() => setIsEditing(true)}>
                  <Edit3 className="h-4 w-4 mr-2" />
                  Rename
                </DropdownMenuItem>
                <DropdownMenuItem onClick={handleOpenPage}>
                  <ExternalLink className="h-4 w-4 mr-2" />
                  Open Page
                </DropdownMenuItem>
                <DropdownMenuSeparator />
                <DropdownMenuItem 
                  onClick={handleDeletePage}
                  className="text-red-600"
                >
                  <Trash2 className="h-4 w-4 mr-2" />
                  Delete Page
                </DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          </div>
        </div>
      </div>
    )
  }

  if (isEditing) {
    // Modo de edição do título
    return (
      <div className="border-2 border-blue-300 rounded-lg p-4 bg-blue-50">
        <div className="space-y-3">
          <div className="flex items-center space-x-3">
            <div className="text-2xl">{selectedIcon}</div>
            <Input
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              onKeyDown={handleKeyDown}
              placeholder="Enter page title..."
              className="flex-1 text-lg font-medium"
              autoFocus
            />
          </div>
          
          <div className="flex justify-end space-x-2">
            <Button 
              variant="outline" 
              size="sm"
              onClick={() => {
                setIsEditing(false)
                setTitle(content.title || 'Untitled Page')
              }}
            >
              Cancel
            </Button>
            <Button 
              size="sm"
              onClick={handleEditTitle}
              disabled={!title.trim()}
            >
              Save
            </Button>
          </div>
        </div>
      </div>
    )
  }

  // Formulário de criação de nova página
  return (
    <div className="border-2 border-dashed border-gray-300 rounded-lg p-6 bg-gray-50 hover:bg-gray-100 transition-colors">
      <div className="text-center space-y-4">
        <div className="flex justify-center">
          <FileText className="h-8 w-8 text-gray-400" />
        </div>
        
        <div className="space-y-3">
          <h3 className="text-lg font-medium text-gray-900">Create Sub-page</h3>
          
          {/* Icon Selector */}
          <div className="grid grid-cols-6 gap-2 max-w-xs mx-auto">
            {pageIcons.map((icon) => (
              <button
                key={icon}
                onClick={() => setSelectedIcon(icon)}
                className={`text-2xl p-2 rounded hover:bg-white transition-colors ${
                  selectedIcon === icon ? 'bg-white ring-2 ring-blue-500' : ''
                }`}
              >
                {icon}
              </button>
            ))}
          </div>
          
          {/* Title Input */}
          <div className="space-y-2">
            <Input
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              onKeyDown={handleKeyDown}
              placeholder="Enter page title..."
              className="text-center"
            />
          </div>
          
          {/* Actions */}
          <div className="flex justify-center space-x-2">
            <Button
              onClick={handleCreatePage}
              disabled={isCreating || !title.trim()}
              className="bg-blue-600 hover:bg-blue-700"
            >
              {isCreating ? (
                <div className="flex items-center space-x-2">
                  <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                  <span>Creating...</span>
                </div>
              ) : (
                <>
                  <Plus className="h-4 w-4 mr-2" />
                  Create Sub-page
                </>
              )}
            </Button>
          </div>
        </div>
        
        <p className="text-sm text-gray-500">
          This will create a new page inside the current page
        </p>
      </div>
    </div>
  )
}
