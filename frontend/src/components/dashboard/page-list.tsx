'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { usePageStore } from '@/lib/stores/page'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { 
  FileText, 
  Plus, 
  Calendar, 
  User, 
  MoreHorizontal, 
  Grid3X3, 
  List,
  Search,
  Filter
} from 'lucide-react'
import { Input } from '@/components/ui/input'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import { formatDate } from '@/lib/utils'

interface PageListProps {
  workspaceId: string
}

type ViewMode = 'list' | 'grid'

export function PageList({ workspaceId }: PageListProps) {
  const router = useRouter()
  const { pages, fetchPages, deletePage, isLoading } = usePageStore()
  const [showCreateDialog, setShowCreateDialog] = useState(false)
  const [viewMode, setViewMode] = useState<ViewMode>('list')
  const [searchQuery, setSearchQuery] = useState('')
  const [sortBy, setSortBy] = useState<'name' | 'date' | 'author'>('date')

  useEffect(() => {
    if (workspaceId) {
      fetchPages(workspaceId)
    }
  }, [workspaceId, fetchPages])

  const handlePageClick = (pageId: string) => {
    router.push(`/page/${pageId}`)
  }

  const handleDeletePage = async (pageId: string, e: React.MouseEvent) => {
    e.stopPropagation()
    if (confirm('Are you sure you want to delete this page?')) {
      try {
        await deletePage(pageId)
      } catch (error) {
        console.error('Failed to delete page:', error)
      }
    }
  }

  // Filter and sort pages
  const filteredPages = pages
    .filter(page => 
      page.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
      page.creator.name.toLowerCase().includes(searchQuery.toLowerCase())
    )
    .sort((a, b) => {
      switch (sortBy) {
        case 'name':
          return a.title.localeCompare(b.title)
        case 'author':
          return a.creator.name.localeCompare(b.creator.name)
        case 'date':
        default:
          return new Date(b.updatedAt).getTime() - new Date(a.updatedAt).getTime()
      }
    })

  if (isLoading) {
    return (
      <div className="space-y-4">
        {[...Array(5)].map((_, i) => (
          <div key={i} className="animate-pulse">
            <div className="h-16 bg-gray-200 rounded-lg"></div>
          </div>
        ))}
      </div>
    )
  }

  if (pages.length === 0) {
    return (
      <div className="text-center py-12">
        <FileText className="mx-auto h-12 w-12 text-gray-400 mb-4" />
        <h3 className="text-lg font-medium text-gray-900 mb-2">No pages yet</h3>
        <p className="text-gray-500 mb-6">
          Get started by creating your first page
        </p>
        <Button onClick={() => setShowCreateDialog(true)}>
          <Plus className="h-4 w-4 mr-2" />
          Create your first page
        </Button>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header with controls */}
      <div className="flex items-center justify-between">
        <h2 className="text-2xl font-bold text-gray-900">Pages</h2>
        
        <div className="flex items-center space-x-4">
          {/* Search */}
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
            <Input
              placeholder="Search pages..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="pl-9 w-64"
            />
          </div>

          {/* Sort */}
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="outline" size="sm">
                <Filter className="h-4 w-4 mr-2" />
                Sort by {sortBy}
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent>
              <DropdownMenuItem onClick={() => setSortBy('date')}>
                Last modified
              </DropdownMenuItem>
              <DropdownMenuItem onClick={() => setSortBy('name')}>
                Name
              </DropdownMenuItem>
              <DropdownMenuItem onClick={() => setSortBy('author')}>
                Author
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>

          {/* View Mode Toggle */}
          <div className="flex items-center border rounded-lg">
            <Button
              variant={viewMode === 'list' ? 'default' : 'ghost'}
              size="sm"
              onClick={() => setViewMode('list')}
              className="rounded-r-none"
            >
              <List className="h-4 w-4" />
            </Button>
            <Button
              variant={viewMode === 'grid' ? 'default' : 'ghost'}
              size="sm"
              onClick={() => setViewMode('grid')}
              className="rounded-l-none"
            >
              <Grid3X3 className="h-4 w-4" />
            </Button>
          </div>

          <Button onClick={() => setShowCreateDialog(true)}>
            <Plus className="h-4 w-4 mr-2" />
            New Page
          </Button>
        </div>
      </div>

      {/* Pages List/Grid */}
      {viewMode === 'list' ? (
        <div className="space-y-2">
          {filteredPages.map((page) => (
            <div
              key={page.id}
              className="flex items-center p-4 bg-white border rounded-lg hover:shadow-md transition-shadow cursor-pointer group"
              onClick={() => handlePageClick(page.id)}
            >
              {/* Icon */}
              <div className="flex-shrink-0 mr-4">
                <span className="text-2xl">{page.icon || '📄'}</span>
              </div>

              {/* Content */}
              <div className="flex-1 min-w-0">
                <div className="flex items-center justify-between">
                  <h3 className="text-lg font-medium text-gray-900 truncate">
                    {page.title}
                  </h3>
                  <div className="flex items-center space-x-4 text-sm text-gray-500">
                    <div className="flex items-center">
                      <User className="h-3 w-3 mr-1" />
                      {page.creator.name}
                    </div>
                    <div className="flex items-center">
                      <Calendar className="h-3 w-3 mr-1" />
                      {formatDate(page.updatedAt)}
                    </div>
                  </div>
                </div>
                
                {/* Breadcrumb if it's a subpage */}
                {page.parentId && (
                  <div className="text-sm text-gray-500 mt-1">
                    <span className="text-gray-400">in</span> Parent Page
                  </div>
                )}
              </div>

              {/* Actions */}
              <div className="flex-shrink-0 ml-4">
                <DropdownMenu>
                  <DropdownMenuTrigger asChild>
                    <Button
                      variant="ghost"
                      size="sm"
                      className="opacity-0 group-hover:opacity-100 transition-opacity"
                      onClick={(e) => e.stopPropagation()}
                    >
                      <MoreHorizontal className="h-4 w-4" />
                    </Button>
                  </DropdownMenuTrigger>
                  <DropdownMenuContent align="end">
                    <DropdownMenuItem onClick={() => handlePageClick(page.id)}>
                      Open
                    </DropdownMenuItem>
                    <DropdownMenuItem>
                      Duplicate
                    </DropdownMenuItem>
                    <DropdownMenuItem>
                      Move to...
                    </DropdownMenuItem>
                    <DropdownMenuSeparator />
                    <DropdownMenuItem 
                      onClick={(e) => handleDeletePage(page.id, e)}
                      className="text-red-600"
                    >
                      Delete
                    </DropdownMenuItem>
                  </DropdownMenuContent>
                </DropdownMenu>
              </div>
            </div>
          ))}
        </div>
      ) : (
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
          {filteredPages.map((page) => (
            <Card 
              key={page.id} 
              className="cursor-pointer hover:shadow-lg transition-shadow duration-200 group"
              onClick={() => handlePageClick(page.id)}
            >
              <CardHeader className="pb-3">
                <div className="flex items-start justify-between">
                  <div className="flex items-center space-x-2">
                    <span className="text-lg">{page.icon || '📄'}</span>
                    <CardTitle className="text-lg truncate">{page.title}</CardTitle>
                  </div>
                  <DropdownMenu>
                    <DropdownMenuTrigger asChild>
                      <Button
                        variant="ghost"
                        size="sm"
                        className="opacity-0 group-hover:opacity-100 transition-opacity"
                        onClick={(e) => e.stopPropagation()}
                      >
                        <MoreHorizontal className="h-4 w-4" />
                      </Button>
                    </DropdownMenuTrigger>
                    <DropdownMenuContent align="end">
                      <DropdownMenuItem onClick={() => handlePageClick(page.id)}>
                        Open
                      </DropdownMenuItem>
                      <DropdownMenuItem>
                        Duplicate
                      </DropdownMenuItem>
                      <DropdownMenuSeparator />
                      <DropdownMenuItem 
                        onClick={(e) => handleDeletePage(page.id, e)}
                        className="text-red-600"
                      >
                        Delete
                      </DropdownMenuItem>
                    </DropdownMenuContent>
                  </DropdownMenu>
                </div>
              </CardHeader>
              
              <CardContent>
                <div className="space-y-2">
                  <div className="flex items-center text-sm text-gray-500">
                    <Calendar className="h-3 w-3 mr-1" />
                    {formatDate(page.updatedAt)}
                  </div>
                  <div className="flex items-center text-sm text-gray-500">
                    <User className="h-3 w-3 mr-1" />
                    {page.creator.name}
                  </div>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      )}

      {filteredPages.length === 0 && searchQuery && (
        <div className="text-center py-8">
          <Search className="mx-auto h-8 w-8 text-gray-400 mb-2" />
          <p className="text-gray-500">No pages found matching "{searchQuery}"</p>
        </div>
      )}
    </div>
  )
}
