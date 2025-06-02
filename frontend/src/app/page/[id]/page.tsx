'use client'

import { useEffect, useState } from 'react'
import { useParams, useRouter } from 'next/navigation'
import { useAuthStore } from '@/lib/stores/auth'
import { usePageStore } from '@/lib/stores/page'
import { useCollaboration } from '@/hooks/use-collaboration'
import { Sidebar } from '@/components/dashboard/sidebar'
import { PageHeader } from '@/components/page/page-header'
import { BlockEditor } from '@/components/editor/block-editor'
import { CommentsSidebar } from '@/components/page/comments-sidebar'
import { Button } from '@/components/ui/button'
import { MessageSquare, X } from 'lucide-react'

export default function PageView() {
  const params = useParams()
  const router = useRouter()
  const { user } = useAuthStore()
  const { currentPage, fetchPage, updatePage } = usePageStore()
  const [showComments, setShowComments] = useState(false)
  
  const pageId = params.id as string

  // Setup real-time collaboration
  useCollaboration(pageId)

  useEffect(() => {
    if (!user) {
      router.push('/')
      return
    }

    if (pageId) {
      fetchPage(pageId)
    }
  }, [user, pageId, fetchPage, router])

  if (!user || !currentPage) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-primary"></div>
      </div>
    )
  }

  return (
    <div className="h-screen flex">
      <Sidebar />
      
      <div className="flex-1 flex flex-col">
        <PageHeader 
          page={currentPage}
          onUpdate={updatePage}
        />

        <div className="flex-1 flex">
          <main className="flex-1 overflow-auto">
            <div className="max-w-4xl mx-auto p-6">
              <BlockEditor pageId={pageId} />
            </div>
          </main>

          {showComments && (
            <CommentsSidebar 
              pageId={pageId}
              onClose={() => setShowComments(false)}
            />
          )}
        </div>

        <div className="fixed bottom-6 right-6">
          <Button
            onClick={() => setShowComments(!showComments)}
            className="rounded-full h-12 w-12 p-0"
          >
            {showComments ? (
              <X className="h-5 w-5" />
            ) : (
              <MessageSquare className="h-5 w-5" />
            )}
          </Button>
        </div>
      </div>
    </div>
  )
}
