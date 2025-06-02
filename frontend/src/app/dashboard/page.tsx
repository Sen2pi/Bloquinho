'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { useAuthStore } from '@/lib/stores/auth'
import { useWorkspaceStore } from '@/lib/stores/workspace'
import { Sidebar } from '@/components/dashboard/sidebar'
import { WorkspaceSelector } from '@/components/dashboard/workspace-selector'
import { PageList } from '@/components/dashboard/page-list'
import { CreatePageDialog } from '@/components/dashboard/create-page-dialog'
import { Button } from '@/components/ui/button'
import { Plus } from 'lucide-react'

export default function DashboardPage() {
  const router = useRouter()
  const { user, logout } = useAuthStore()
  const { workspaces, currentWorkspace, fetchWorkspaces, setCurrentWorkspace } = useWorkspaceStore()
  const [showCreatePage, setShowCreatePage] = useState(false)

  useEffect(() => {
    if (!user) {
      router.push('/')
      return
    }

    fetchWorkspaces()
  }, [user, fetchWorkspaces, router])

  useEffect(() => {
    if (workspaces.length > 0 && !currentWorkspace) {
      setCurrentWorkspace(workspaces[0])
    }
  }, [workspaces, currentWorkspace, setCurrentWorkspace])

  if (!user) {
    return null
  }

  return (
    <div className="h-screen flex">
      <Sidebar />
      
      <div className="flex-1 flex flex-col">
        <header className="border-b p-4 flex items-center justify-between">
          <div className="flex items-center space-x-4">
            <WorkspaceSelector />
            <h1 className="text-xl font-semibold">
              {currentWorkspace?.name || 'Dashboard'}
            </h1>
          </div>
          
          <div className="flex items-center space-x-2">
            <Button onClick={() => setShowCreatePage(true)}>
              <Plus className="h-4 w-4 mr-2" />
              New Page
            </Button>
            <Button variant="outline" onClick={logout}>
              Logout
            </Button>
          </div>
        </header>

        <main className="flex-1 p-6">
          {currentWorkspace ? (
            <PageList workspaceId={currentWorkspace.id} />
          ) : (
            <div className="text-center py-12">
              <p className="text-gray-500">Select a workspace to get started</p>
            </div>
          )}
        </main>
      </div>

      <CreatePageDialog
        open={showCreatePage}
        onOpenChange={setShowCreatePage}
        workspaceId={currentWorkspace?.id}
      />
    </div>
  )
}
