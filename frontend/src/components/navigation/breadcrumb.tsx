'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { Button } from '@/components/ui/button'
import { ChevronRight, Home, ArrowLeft } from 'lucide-react'

interface BreadcrumbProps {
  pageId?: string
  workspaceId?: string
}

export function Breadcrumb({ pageId, workspaceId }: BreadcrumbProps) {
  const router = useRouter()

  const handleBack = () => {
    router.back()
  }

  const handleHome = () => {
    router.push('/dashboard')
  }

  return (
    <div className="flex items-center space-x-2 p-4 border-b bg-white sticky top-0 z-30">
      <Button
        variant="ghost"
        size="sm"
        onClick={handleBack}
        className="mr-2 hover:bg-gray-100"
      >
        <ArrowLeft className="h-4 w-4" />
      </Button>

      <Button
        variant="ghost"
        size="sm"
        onClick={handleHome}
        className="hover:bg-gray-100"
      >
        <Home className="h-4 w-4" />
      </Button>

      <ChevronRight className="h-4 w-4 text-gray-400" />
      
      <Button
        variant="ghost"
        size="sm"
        className="font-semibold"
      >
        Current Page
      </Button>
    </div>
  )
}
