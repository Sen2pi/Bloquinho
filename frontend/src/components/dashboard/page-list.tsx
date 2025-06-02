'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { usePageStore } from '@/lib/stores/page'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { FileText, Plus, Calendar, User, MoreHorizontal } from 'lucide-react'
import { formatDate } from '@/lib/utils'

interface PageListProps {
  workspaceId: string
}

export function PageList({ workspaceId }: PageListProps) {
  const router = useRouter()
  const { pages, fetchPages, deletePage, isLoading } = usePageStore()
  const [showCreateDialog, setShowCreateDialog] = useState(false)

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

  if (isLoading) {
    return (
      <div className="space-y-4">
        {[...Array(3)].map((_, i) => (
          <Card key={i} className="animate-pulse">
            <CardHeader>
              <div className="h-4 bg-gray-200 rounded w-3/4"></div>
              <div className="h-3 bg-gray-200 rounded w-1/2"></div>
            </CardHeader>
          </Card>
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
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h2 className="text-2xl font-bold text-gray-900">Pages</h2>
        <Button onClick={() => setShowCreateDialog(true)}>
          <Plus className="h-4 w-4 mr-2" />
          New Page
        </Button>
      </div>

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
        {pages.map((page) => (
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
                <Button
                  variant="ghost"
                  size="sm"
                  className="opacity-0 group-hover:opacity-100 transition-opacity"
                  onClick={(e) => handleDeletePage(page.id, e)}
                >
                  <MoreHorizontal className="h-4 w-4" />
                </Button>
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
    </div>
  )
}
