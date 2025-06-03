'use client'

import { useEffect, useState } from 'react'
import { useParams, useRouter } from 'next/navigation'
import { useAuthStore } from '@/lib/stores/auth'
import { usePageStore } from '@/lib/stores/page'
import { Sidebar } from '@/components/dashboard/sidebar'
import { PageHeader } from '@/components/page/page-header'
import { MainEditor } from '@/components/editor/main-editor'
import { Breadcrumb } from '@/components/navigation/breadcrumb'
import { GlobalSearch } from '@/components/search/global-search'
import { ExportManager } from '@/components/import-export/export-manager'
import { Button } from '@/components/ui/button'
import { MessageSquare } from 'lucide-react'

export default function PageView() {
  const params = useParams()
  const router = useRouter()
  const { user } = useAuthStore()
  const { currentPage, fetchPage, updatePage } = usePageStore()
  const [showComments, setShowComments] = useState(false)
  
  const pageId = params.id as string

  useEffect(() => {
    if (!user) {
      router.push('/')
      return
    }

    if (pageId) {
      fetchPage(pageId)
    }
  }, [user, pageId, fetchPage, router])

  if (!user) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Loading...</p>
        </div>
      </div>
    )
  }

  if (!currentPage) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Loading page...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="h-screen flex bg-gray-50">
      <Sidebar />
      
      <div className="flex-1 flex flex-col">
        <Breadcrumb pageId={pageId} />
        
        <div className="absolute top-4 right-4 z-50">
          <GlobalSearch />
        </div>

        <PageHeader 
          page={currentPage}
          onUpdate={updatePage}
        />

        <main className="flex-1 overflow-auto">
          <div className="max-w-7xl mx-auto p-6">
            <div className="flex items-center justify-between mb-6">
              <ExportManager
                pageId={pageId}
                pageTitle={currentPage.title}
                pageContent={[]}
              />
              
              <Button
                variant="outline"
                size="sm"
                onClick={() => setShowComments(!showComments)}
              >
                <MessageSquare className="h-4 w-4 mr-2" />
                Comments
              </Button>
            </div>

            <div id="page-content">
              <MainEditor pageId={pageId} />
            </div>
          </div>
        </main>
      </div>
    </div>
  )
}
