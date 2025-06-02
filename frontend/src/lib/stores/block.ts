import { create } from 'zustand'
import axios from 'axios'

interface Block {
  id: string
  type: string
  content: any
  parentId?: string
  pageId: string
  order: number
  createdBy: string
  createdAt: string
  updatedAt: string
  creator: {
    id: string
    name: string
  }
  children?: Block[]
}

interface BlockState {
  blocks: Block[]
  isLoading: boolean
  fetchBlocks: (pageId: string) => Promise<void>
  createBlock: (data: {
    type: string
    content: any
    pageId: string
    parentId?: string
    order: number
  }) => Promise<void>
  updateBlock: (id: string, data: Partial<Block>) => Promise<void>
  deleteBlock: (id: string) => Promise<void>
  reorderBlocks: (updates: Array<{ id: string; order: number }>) => Promise<void>
}

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'

export const useBlockStore = create<BlockState>((set, get) => ({
  blocks: [],
  isLoading: false,

  fetchBlocks: async (pageId) => {
    set({ isLoading: true })
    try {
      const response = await axios.get(`${API_URL}/api/pages/${pageId}`)
      const blocks = response.data.blocks || []
      set({ blocks: blocks.sort((a: Block, b: Block) => a.order - b.order), isLoading: false })
    } catch (error) {
      console.error('Failed to fetch blocks:', error)
      set({ isLoading: false })
    }
  },

  createBlock: async (data) => {
    try {
      const response = await axios.post(`${API_URL}/api/blocks`, data)
      const newBlock = response.data

      set(state => ({
        blocks: [...state.blocks, newBlock].sort((a, b) => a.order - b.order)
      }))
    } catch (error) {
      console.error('Failed to create block:', error)
      throw error
    }
  },

  updateBlock: async (id, data) => {
    try {
      const response = await axios.put(`${API_URL}/api/blocks/${id}`, data)
      const updatedBlock = response.data

      set(state => ({
        blocks: state.blocks.map(b => b.id === id ? updatedBlock : b)
      }))
    } catch (error) {
      console.error('Failed to update block:', error)
      throw error
    }
  },

  deleteBlock: async (id) => {
    try {
      await axios.delete(`${API_URL}/api/blocks/${id}`)
      
      set(state => ({
        blocks: state.blocks.filter(b => b.id !== id)
      }))
    } catch (error) {
      console.error('Failed to delete block:', error)
      throw error
    }
  },

  reorderBlocks: async (updates) => {
    try {
      await axios.put(`${API_URL}/api/blocks/reorder`, { blocks: updates })
      
      // Update local state
      set(state => {
        const newBlocks = [...state.blocks]
        updates.forEach(update => {
          const blockIndex = newBlocks.findIndex(b => b.id === update.id)
          if (blockIndex !== -1) {
            newBlocks[blockIndex].order = update.order
          }
        })
        return { blocks: newBlocks.sort((a, b) => a.order - b.order) }
      })
    } catch (error) {
      console.error('Failed to reorder blocks:', error)
      throw error
    }
  }
}))
