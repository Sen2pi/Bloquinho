import { create } from 'zustand'
import { persist } from 'zustand/middleware'
import axios from 'axios'

interface User {
  id: string
  email: string
  name: string
}

interface AuthState {
  user: User | null
  token: string | null
  isLoading: boolean
  login: (email: string, password: string) => Promise<void>
  register: (email: string, name: string, password: string) => Promise<void>
  logout: () => void
  checkAuth: () => void
}

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'

export const useAuthStore = create<AuthState>()(
  persist(
    (set, get) => ({
      user: null,
      token: null,
      isLoading: true,

      login: async (email: string, password: string) => {
        try {
          const response = await axios.post(`${API_URL}/api/auth/login`, {
            email,
            password,
          })

          const { user, token } = response.data

          // Set axios default header
          axios.defaults.headers.common['Authorization'] = `Bearer ${token}`

          set({ user, token, isLoading: false })
        } catch (error: any) {
          throw new Error(error.response?.data?.error || 'Login failed')
        }
      },

      register: async (email: string, name: string, password: string) => {
        try {
          const response = await axios.post(`${API_URL}/api/auth/register`, {
            email,
            name,
            password,
          })

          const { user, token } = response.data

          // Set axios default header
          axios.defaults.headers.common['Authorization'] = `Bearer ${token}`

          set({ user, token, isLoading: false })
        } catch (error: any) {
          throw new Error(error.response?.data?.error || 'Registration failed')
        }
      },

      logout: () => {
        // Remove axios default header
        delete axios.defaults.headers.common['Authorization']
        
        set({ user: null, token: null, isLoading: false })
      },

      checkAuth: () => {
        const { token } = get()
        
        if (token) {
          // Set axios default header
          axios.defaults.headers.common['Authorization'] = `Bearer ${token}`
        }
        
        set({ isLoading: false })
      },
    }),
    {
      name: 'auth-storage',
      partialize: (state) => ({
        user: state.user,
        token: state.token,
      }),
    }
  )
)

// Initialize auth check
if (typeof window !== 'undefined') {
  useAuthStore.getState().checkAuth()
}
