'use client'

import { useState } from 'react'
import { useWorkspaceStore } from '@/lib/stores/workspace'
import { Button } from '@/components/ui/button'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import { ChevronDown, Plus, Settings } from 'lucide-react'
import { CreateWorkspaceDialog } from './create-workspace-dialog'

export function WorkspaceSelector() {
  const { workspaces, currentWorkspace, setCurrentWorkspace } = useWorkspaceStore()
  const [showCreateDialog, setShowCreateDialog] = useState(false)

  return (
    <>
      <DropdownMenu>
        <DropdownMenuTrigger asChild>
          <Button variant="outline" className="justify-between min-w-[200px]">
            <div className="flex items-center space-x-2">
              <div className="w-5 h-5 bg-blue-500 rounded flex items-center justify-center text-white text-xs font-bold">
                {currentWorkspace?.name?.charAt(0) || 'W'}
              </div>
              <span className="truncate">{currentWorkspace?.name || 'Select Workspace'}</span>
            </div>
            <ChevronDown className="h-4 w-4" />
          </Button>
        </DropdownMenuTrigger>
        
        <DropdownMenuContent className="w-[200px]">
          {workspaces.map((workspace) => (
            <DropdownMenuItem
              key={workspace.id}
              onClick={() => setCurrentWorkspace(workspace)}
              className="flex items-center space-x-2"
            >
              <div className="w-5 h-5 bg-blue-500 rounded flex items-center justify-center text-white text-xs font-bold">
                {workspace.name.charAt(0)}
              </div>
              <span className="truncate">{workspace.name}</span>
            </DropdownMenuItem>
          ))}
          
          <DropdownMenuSeparator />
          
          <DropdownMenuItem onClick={() => setShowCreateDialog(true)}>
            <Plus className="h-4 w-4 mr-2" />
            Create Workspace
          </DropdownMenuItem>
          
          <DropdownMenuItem>
            <Settings className="h-4 w-4 mr-2" />
            Workspace Settings
          </DropdownMenuItem>
        </DropdownMenuContent>
      </DropdownMenu>

      <CreateWorkspaceDialog
        open={showCreateDialog}
        onOpenChange={setShowCreateDialog}
      />
    </>
  )
}
