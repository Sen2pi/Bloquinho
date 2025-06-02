import { create } from 'zustand'
import axios from 'axios'

interface Database {
  id: string
  name: string
  description?: string
  properties: Record<string, any>
  rows?: DatabaseRow[]
  createdAt: string
  updatedAt: string
}

interface DatabaseRow {
  id: string
  databaseId: string
  data: Record<string, any>
  createdAt: string
  updatedAt: string
}

interface DatabaseState {
  databases: Database[]
  currentDatabase: Database | null
  isLoading: boolean
  fetchDatabase: (id: string) => Promise<void>
  createDatabase: (data: {
    name: string
    description?: string
    properties: Record<string, any>
  }) => Promise<Database>
  updateDatabase: (id: string, data: Partial<Database>) => Promise<void>
}

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'

export const useDatabaseStore = create<DatabaseState>((set, get) => ({
  databases: [],
  currentDatabase: null,
  isLoading: false,

  fetchDatabase: async (id) => {
    set({ isLoading: true })
    try {
      const response = await axios.get(`${API_URL}/api/databases/${id}`)
      set({ currentDatabase: response.data, isLoading: false })
    } catch (error) {
      console.error('Failed to fetch database:', error)
      set({ isLoading: false })
    }
  },

  createDatabase: async (data) => {
    try {
      const response = await axios.post(`${API_URL}/api/databases`, data)
      const newDatabase = response.data
      
      set(state => ({
        databases: [...state.databases, newDatabase]
      }))

      return newDatabase
    } catch (error) {
      console.error('Failed to create database:', error)
      throw error
    }
  },

  updateDatabase: async (id, data) => {
    try {
      const response = await axios.put(`${API_URL}/api/databases/${id}`, data)
      const updatedDatabase = response.data

      set(state => ({
        databases: state.databases.map(db => 
          db.id === id ? updatedDatabase : db
        ),
        currentDatabase: state.currentDatabase?.id === id 
          ? updatedDatabase 
          : state.currentDatabase
      }))
    } catch (error) {
      console.error('Failed to update database:', error)
      throw error
    }
  }
}))
