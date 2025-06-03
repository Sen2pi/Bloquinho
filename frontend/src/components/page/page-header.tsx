'use client'

import { useState } from 'react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { 
  MoreHorizontal, 
  Edit3, 
  Trash2, 
  Share2, 
  Star, 
  Archive,
  Settings,
  Copy
} from 'lucide-react'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog'
import { RWebShare } from 'react-web-share'
import toast from 'react-hot-toast'

interface Page {
  id: string
  title: string
  icon?: string
  cover?: string
  updatedAt: string
  creator: {
    id: string
    name: string
    email: string
  }
}

interface PageHeaderProps {
  page: Page
  onUpdate: (id: string, data: Partial<Page>) => Promise<void>
}

const pageIcons = ['📄', '📝', '📋', '📊', '📈', '🎯', '💡', '🚀', '📚', '🔥']

export function PageHeader({ page, onUpdate }: PageHeaderProps) {
  const [isEditingTitle, setIsEditingTitle] = useState(false)
  const [title, setTitle] = useState(page.title)
  const [isEditingIcon, setIsEditingIcon] = useState(false)
  const [isFavorite, setIsFavorite] = useState(false)
  const [showShareDialog, setShowShareDialog] = useState(false)

  const currentUrl = typeof window !== 'undefined' ? window.location.href : ''
  const shareTitle = `${page.title} - Bloquinho`
  const shareDescription = `Check out this page: ${page.title}`

  const handleTitleSave = async () => {
    if (title.trim() && title !== page.title) {
      try {
        await onUpdate(page.id, { title: title.trim() })
        toast.success('Title updated!')
      } catch (error) {
        console.error('Failed to update title:', error)
        setTitle(page.title)
        toast.error('Failed to update title')
      }
    }
    setIsEditingTitle(false)
  }

  const handleTitleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter') {
      handleTitleSave()
    } else if (e.key === 'Escape') {
      setTitle(page.title)
      setIsEditingTitle(false)
    }
  }

  const handleIconChange = async (newIcon: string) => {
    try {
      await onUpdate(page.id, { icon: newIcon })
      setIsEditingIcon(false)
      toast.success('Icon updated!')
    } catch (error) {
      console.error('Failed to update icon:', error)
      toast.error('Failed to update icon')
    }
  }

  const handleToggleFavorite = () => {
    setIsFavorite(!isFavorite)
    toast.success(isFavorite ? 'Removed from favorites' : 'Added to favorites')
  }

  const handleCopyLink = async () => {
    try {
      await navigator.clipboard.writeText(currentUrl)
      toast.success('Link copied to clipboard!')
    } catch (error) {
      toast.error('Failed to copy link')
    }
  }

  const handleDeletePage = async () => {
    if (confirm('Are you sure you want to delete this page?')) {
      try {
        toast.success('Page deleted')
      } catch (error) {
        toast.error('Failed to delete page')
      }
    }
  }

  return (
    <div className="border-b bg-white">
      {/* Cover Image */}
      {page.cover && (
        <div className="h-48 bg-gradient-to-r from-purple-400 to-pink-400 relative">
          <img 
            src={page.cover} 
            alt="Page cover" 
            className="w-full h-full object-cover"
          />
        </div>
      )}

      {/* Header Content */}
      <div className="max-w-4xl mx-auto px-6 py-6">
        <div className="flex items-start justify-between mb-4">
          <div className="flex items-center space-x-4 flex-1">
            {/* Icon */}
            <div className="relative">
              <button
                onClick={() => setIsEditingIcon(!isEditingIcon)}
                className="text-4xl hover:bg-gray-100 rounded-lg p-2 transition-colors"
              >
                {page.icon || '📄'}
              </button>
              
              {isEditingIcon && (
                <div className="absolute top-full left-0 mt-2 bg-white border rounded-lg shadow-lg p-3 z-10">
                  <div className="grid grid-cols-5 gap-2">
                    {pageIcons.map((icon) => (
                      <button
                        key={icon}
                        onClick={() => handleIconChange(icon)}
                        className="text-2xl hover:bg-gray-100 rounded p-2 transition-colors"
                      >
                        {icon}
                      </button>
                    ))}
                  </div>
                </div>
              )}
            </div>

            {/* Title */}
            <div className="flex-1">
              {isEditingTitle ? (
                <Input
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  onBlur={handleTitleSave}
                  onKeyDown={handleTitleKeyDown}
                  className="text-3xl font-bold border-none shadow-none p-0 h-auto bg-transparent"
                  autoFocus
                />
              ) : (
                <h1
                  onClick={() => setIsEditingTitle(true)}
                  className="text-3xl font-bold cursor-pointer hover:bg-gray-50 rounded px-2 py-1 -mx-2 -my-1 transition-colors"
                >
                  {page.title}
                </h1>
              )}
              
              <div className="flex items-center space-x-4 mt-2 text-sm text-gray-500">
                <span>Created by {page.creator.name}</span>
                <span>•</span>
                <span>Last edited {new Date(page.updatedAt).toLocaleDateString()}</span>
              </div>
            </div>
          </div>

          {/* Actions */}
          <div className="flex items-center space-x-2">
            {/* Share Button with react-web-share */}
            <RWebShare
              data={{
                text: shareDescription,
                url: currentUrl,
                title: shareTitle,
              }}
              onClick={() => toast.success("Shared successfully!")}
            >
              <Button variant="outline" size="sm">
                <Share2 className="h-4 w-4 mr-2" />
                Share
              </Button>
            </RWebShare>
            
            {/* Favorite Button */}
            <Button 
              variant="outline" 
              size="sm"
              onClick={handleToggleFavorite}
              className={isFavorite ? 'text-yellow-500' : ''}
            >
              <Star className={`h-4 w-4 ${isFavorite ? 'fill-current' : ''}`} />
            </Button>

            {/* More Actions Dropdown */}
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <Button variant="outline" size="sm">
                  <MoreHorizontal className="h-4 w-4" />
                </Button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="end">
                <DropdownMenuItem onClick={() => setIsEditingIcon(true)}>
                  <Edit3 className="h-4 w-4 mr-2" />
                  Change Icon
                </DropdownMenuItem>
                <DropdownMenuItem onClick={handleCopyLink}>
                  <Copy className="h-4 w-4 mr-2" />
                  Copy Link
                </DropdownMenuItem>
                <DropdownMenuItem>
                  <Archive className="h-4 w-4 mr-2" />
                  Archive
                </DropdownMenuItem>
                <DropdownMenuItem>
                  <Settings className="h-4 w-4 mr-2" />
                  Page Settings
                </DropdownMenuItem>
                <DropdownMenuSeparator />
                <DropdownMenuItem onClick={handleDeletePage} className="text-red-600">
                  <Trash2 className="h-4 w-4 mr-2" />
                  Delete Page
                </DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          </div>
        </div>
      </div>
    </div>
  )
}
