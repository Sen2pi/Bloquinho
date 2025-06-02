import { create } from 'zustand'
import axios from 'axios'

interface Page {
  id: string
  title: string
  icon?: string
  cover?: string
  parentId?: string
  workspaceId: string
  createdBy: string
  createdAt: string
  updatedAt: string
  creator: {
    id: string
    name: string
    email: string
  }
  children?: Page[]
  blocks?: any[]
}

interface PageState {
  pages: Page[]
  currentPage: Page | null
  isLoading: boolean
  fetchPages: (workspaceId: string) => Promise<void>
  fetchPage: (id: string) => Promise<void>
  createPage: (data: {
    title: string
    workspaceId: string
    parentId?: string
    icon?: string
    cover?: string
  }) => Promise<Page>
  updatePage: (id: string, data: Partial<Page>) => Promise<void>
  deletePage: (id: string) => Promise<void>
}

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'

export const usePageStore = create<PageState>((set, get) => ({
  pages: [],
  currentPage: null,
  isLoading: false,

  fetchPages: async (workspaceId) => {
    set({ isLoading: true })
    try {
      const response = await axios.get(`${API_URL}/api/pages/workspace/${workspaceId}`)
      set({ pages: response.data, isLoading: false })
    } catch (error) {
      console.error('Failed to fetch pages:', error)
      set({ isLoading: false })
    }
  },

  fetchPage: async (id) => {
    set({ isLoading: true })
    try {
      const response = await axios.get(`${API_URL}/api/pages/${id}`)
      set({ currentPage: response.data, isLoading: false })
    } catch (error) {
      console.error('Failed to fetch page:', error)
      set({ isLoading: false })
    }
  },

  createPage: async (data) => {
    try {
      const response = await axios.post(`${API_URL}/api/pages`, data)
      const newPage = response.data

      set(state => ({
        pages: [...state.pages, newPage]
      }))

      return newPage
    } catch (error) {
      console.error('Failed to create page:', error)
      throw error
    }
  },

  updatePage: async (id, data) => {
    try {
      const response = await axios.put(`${API_URL}/api/pages/${id}`, data)
      const updatedPage = response.data

      set(state => ({
        pages: state.pages.map(p => p.id === id ? updatedPage : p),
        currentPage: state.currentPage?.id === id ? updatedPage : state.currentPage
      }))
    } catch (error) {
      console.error('Failed to update page:', error)
      throw error
    }
  },

  deletePage: async (id) => {
    try {
      await axios.delete(`${API_URL}/api/pages/${id}`)
      
      set(state => ({
        pages: state.pages.filter(p => p.id !== id),
        currentPage: state.currentPage?.id === id ? null : state.currentPage
      }))
    } catch (error) {
      console.error('Failed to delete page:', error)
      throw error
    }
  }
}))
