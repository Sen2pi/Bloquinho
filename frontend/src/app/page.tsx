'use client'

import { useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { useAuthStore } from '@/lib/stores/auth'
import { LoginForm } from '@/components/auth/login-form'
import Image from 'next/image'

export default function HomePage() {
  const router = useRouter()
  const { user, isLoading } = useAuthStore()

  useEffect(() => {
    if (user && !isLoading) {
      router.push('/dashboard')
    }
  }, [user, isLoading, router])

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-indigo-50 via-white to-purple-50">
        <div className="relative">
          <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-primary"></div>
          <div className="absolute inset-0 flex items-center justify-center">
            <Image
              src="/logo.png"
              alt="Logo"
              width={40}
              height={40}
              className="animate-pulse"
              priority
            />
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-indigo-50 via-white to-purple-50 relative overflow-hidden">
      {/* Background decorations */}
      <div className="absolute inset-0 overflow-hidden">
        <div className="absolute -top-40 -right-40 w-80 h-80 bg-purple-300 rounded-full mix-blend-multiply filter blur-xl opacity-70 animate-blob"></div>
        <div className="absolute -bottom-40 -left-40 w-80 h-80 bg-yellow-300 rounded-full mix-blend-multiply filter blur-xl opacity-70 animate-blob animation-delay-2000"></div>
        <div className="absolute top-40 left-40 w-80 h-80 bg-pink-300 rounded-full mix-blend-multiply filter blur-xl opacity-70 animate-blob animation-delay-4000"></div>
      </div>

      <div className="relative min-h-screen flex items-center justify-center p-4">
        <div className="max-w-6xl w-full grid lg:grid-cols-2 gap-12 items-center">
          {/* Left side - Branding */}
          <div className="text-center lg:text-left space-y-8 animate-fade-in">
            <div className="flex items-center justify-center lg:justify-start space-x-4">
              <div className="relative">
                <Image
                  src="/logo.png"
                  alt="Bloquinho Logo"
                  width={80}
                  height={80}
                  className="drop-shadow-lg"
                  priority
                />
                <div className="absolute inset-0 bg-gradient-to-r from-purple-400 to-pink-400 rounded-full blur-lg opacity-30 animate-pulse"></div>
              </div>
              <div>
                <h1 className="text-5xl lg:text-6xl font-bold bg-gradient-to-r from-purple-600 to-pink-600 bg-clip-text text-transparent">
                  Bloquinho
                </h1>
                <p className="text-xl text-gray-600 font-medium">
                  Your Personal Workspace
                </p>
              </div>
            </div>
            
            <div className="space-y-6">
              <h2 className="text-3xl lg:text-4xl font-bold text-gray-900 leading-tight">
                Organize your life and work,
                <span className="bg-gradient-to-r from-purple-600 to-pink-600 bg-clip-text text-transparent">
                  {" "}beautifully
                </span>
              </h2>
              
              <p className="text-lg text-gray-600 leading-relaxed max-w-lg">
                A powerful, self-hosted alternative to Notion. Create, collaborate, and organize 
                everything in one place, on your own terms.
              </p>
              
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 pt-4">
                <div className="glass-effect p-4 rounded-xl text-center">
                  <div className="text-2xl font-bold text-purple-600">∞</div>
                  <div className="text-sm text-gray-600">Unlimited blocks</div>
                </div>
                <div className="glass-effect p-4 rounded-xl text-center">
                  <div className="text-2xl font-bold text-pink-600">🔒</div>
                  <div className="text-sm text-gray-600">Self-hosted</div>
                </div>
                <div className="glass-effect p-4 rounded-xl text-center">
                  <div className="text-2xl font-bold text-indigo-600">⚡</div>
                  <div className="text-sm text-gray-600">Real-time sync</div>
                </div>
              </div>
            </div>
          </div>

          {/* Right side - Login Form */}
          <div className="flex justify-center lg:justify-end animate-fade-in">
            <div className="w-full max-w-md">
              <LoginForm />
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
