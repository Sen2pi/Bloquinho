import { create } from 'zustand'
import axios from 'axios'

interface Workspace {
  id: string
  name: string
  description?: string
  icon?: string
  members: Array<{
    id: string
    role: string
    user: {
      id: string
      name: string
      email: string
      avatar?: string
    }
  }>
  _count: {
    pages: number
  }
}

interface WorkspaceState {
  workspaces: Workspace[]
  currentWorkspace: Workspace | null
  isLoading: boolean
  fetchWorkspaces: () => Promise<void>
  createWorkspace: (data: { name: string; description?: string; icon?: string }) => Promise<void>
  updateWorkspace: (id: string, data: Partial<Workspace>) => Promise<void>
  setCurrentWorkspace: (workspace: Workspace) => void
  inviteUser: (workspaceId: string, email: string, role?: string) => Promise<void>
}

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'

export const useWorkspaceStore = create<WorkspaceState>((set, get) => ({
  workspaces: [],
  currentWorkspace: null,
  isLoading: false,

  fetchWorkspaces: async () => {
    set({ isLoading: true })
    try {
      const response = await axios.get(`${API_URL}/api/workspaces`)
      set({ workspaces: response.data, isLoading: false })
    } catch (error) {
      console.error('Failed to fetch workspaces:', error)
      set({ isLoading: false })
    }
  },

  createWorkspace: async (data) => {
    try {
      const response = await axios.post(`${API_URL}/api/workspaces`, data)
      const newWorkspace = response.data
      
      set(state => ({
        workspaces: [...state.workspaces, newWorkspace],
        currentWorkspace: newWorkspace
      }))
    } catch (error) {
      console.error('Failed to create workspace:', error)
      throw error
    }
  },

  updateWorkspace: async (id, data) => {
    try {
      const response = await axios.put(`${API_URL}/api/workspaces/${id}`, data)
      const updatedWorkspace = response.data

      set(state => ({
        workspaces: state.workspaces.map(w => 
          w.id === id ? updatedWorkspace : w
        ),
        currentWorkspace: state.currentWorkspace?.id === id 
          ? updatedWorkspace 
          : state.currentWorkspace
      }))
    } catch (error) {
      console.error('Failed to update workspace:', error)
      throw error
    }
  },

  setCurrentWorkspace: (workspace) => {
    set({ currentWorkspace: workspace })
  },

  inviteUser: async (workspaceId, email, role = 'MEMBER') => {
    try {
      await axios.post(`${API_URL}/api/workspaces/${workspaceId}/invite`, {
        email,
        role
      })
      
      // Refresh workspaces to get updated member list
      get().fetchWorkspaces()
    } catch (error) {
      console.error('Failed to invite user:', error)
      throw error
    }
  }
}))
