'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { useWorkspaceStore } from '@/lib/stores/workspace'
import { usePageStore } from '@/lib/stores/page'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { 
  Search, 
  Plus, 
  Settings, 
  FileText, 
  ChevronRight, 
  ChevronDown,
  Home
} from 'lucide-react'

export function Sidebar() {
  const router = useRouter()
  const { currentWorkspace } = useWorkspaceStore()
  const { pages } = usePageStore()
  const [searchQuery, setSearchQuery] = useState('')
  const [expandedPages, setExpandedPages] = useState<Set<string>>(new Set())

  const togglePageExpansion = (pageId: string) => {
    const newExpanded = new Set(expandedPages)
    if (newExpanded.has(pageId)) {
      newExpanded.delete(pageId)
    } else {
      newExpanded.add(pageId)
    }
    setExpandedPages(newExpanded)
  }

  const filteredPages = pages.filter(page => 
    page.title.toLowerCase().includes(searchQuery.toLowerCase())
  )

  const renderPageTree = (pages: any[], level = 0) => {
    return pages
      .filter(page => level === 0 ? !page.parentId : page.parentId === pages[0]?.id)
      .map(page => (
        <div key={page.id}>
          <div 
            className="flex items-center space-x-2 px-2 py-1 hover:bg-gray-100 rounded cursor-pointer"
            style={{ paddingLeft: `${8 + level * 16}px` }}
          >
            {page.children?.length > 0 && (
              <Button
                variant="ghost"
                size="sm"
                className="h-4 w-4 p-0"
                onClick={() => togglePageExpansion(page.id)}
              >
                {expandedPages.has(page.id) ? (
                  <ChevronDown className="h-3 w-3" />
                ) : (
                  <ChevronRight className="h-3 w-3" />
                )}
              </Button>
            )}
            
            <FileText className="h-4 w-4 text-gray-500" />
            
            <span 
              className="flex-1 text-sm truncate"
              onClick={() => router.push(`/page/${page.id}`)}
            >
              {page.icon} {page.title}
            </span>
          </div>
          
          {expandedPages.has(page.id) && page.children && (
            <div>
              {renderPageTree(page.children, level + 1)}
            </div>
          )}
        </div>
      ))
  }

  return (
    <div className="w-64 bg-gray-50 border-r h-full flex flex-col">
      {/* Header */}
      <div className="p-4 border-b">
        <div className="flex items-center space-x-2 mb-3">
          <div className="w-8 h-8 bg-blue-500 rounded flex items-center justify-center text-white font-bold">
            {currentWorkspace?.name?.charAt(0) || 'W'}
          </div>
          <span className="font-medium truncate">{currentWorkspace?.name}</span>
        </div>
        
        <div className="relative">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
          <Input
            placeholder="Search pages..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="pl-9 h-8"
          />
        </div>
      </div>

      {/* Navigation */}
      <div className="flex-1 overflow-y-auto p-2">
        <div className="space-y-1">
          <Button
            variant="ghost"
            className="w-full justify-start h-8"
            onClick={() => router.push('/dashboard')}
          >
            <Home className="h-4 w-4 mr-2" />
            Dashboard
          </Button>
          
          <Button
            variant="ghost"
            className="w-full justify-start h-8"
            onClick={() => router.push('/templates')}
          >
            <Plus className="h-4 w-4 mr-2" />
            Templates
          </Button>
          
          <Button
            variant="ghost"
            className="w-full justify-start h-8"
            onClick={() => router.push('/settings')}
          >
            <Settings className="h-4 w-4 mr-2" />
            Settings
          </Button>
        </div>

        <div className="mt-6">
          <div className="px-2 py-1 text-xs font-medium text-gray-500 uppercase tracking-wider">
            Pages
          </div>
          <div className="mt-2 space-y-1">
            {renderPageTree(filteredPages)}
          </div>
        </div>
      </div>
    </div>
  )
}
