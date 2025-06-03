'use client'

import { useState, useEffect, useRef } from 'react'
import { useRouter } from 'next/navigation'
import { Input } from '@/components/ui/input'
import { Button } from '@/components/ui/button'
import { Search, FileText, Clock } from 'lucide-react'

export function GlobalSearch() {
  const router = useRouter()
  const [isOpen, setIsOpen] = useState(false)
  const [query, setQuery] = useState('')
  const inputRef = useRef<HTMLInputElement>(null)

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if ((e.metaKey || e.ctrlKey) && e.key === 'k') {
        e.preventDefault()
        setIsOpen(true)
        setTimeout(() => inputRef.current?.focus(), 100)
      }
      
      if (e.key === 'Escape') {
        setIsOpen(false)
        setQuery('')
      }
    }

    document.addEventListener('keydown', handleKeyDown)
    return () => document.removeEventListener('keydown', handleKeyDown)
  }, [])

  if (!isOpen) {
    return (
      <Button
        variant="outline"
        onClick={() => setIsOpen(true)}
        className="w-80 justify-start text-gray-500 hover:bg-gray-50"
      >
        <Search className="h-4 w-4 mr-2" />
        Search anything... 
        <kbd className="ml-auto text-xs bg-gray-100 px-2 py-1 rounded">⌘K</kbd>
      </Button>
    )
  }

  return (
    <div className="fixed inset-0 z-50 bg-black/50 flex items-start justify-center pt-[10vh]">
      <div className="bg-white rounded-xl shadow-2xl w-full max-w-2xl mx-4 max-h-[70vh] flex flex-col">
        <div className="p-4 border-b">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-5 w-5 text-gray-400" />
            <Input
              ref={inputRef}
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder="Search pages, databases, blocks, and more..."
              className="pl-10 pr-4 h-12 text-lg border-0 shadow-none focus:ring-0"
              autoFocus
            />
          </div>
        </div>

        <div className="flex-1 overflow-y-auto p-6">
          <div className="text-center">
            <Search className="h-8 w-8 text-gray-400 mx-auto mb-2" />
            <p className="text-gray-500">Search functionality coming soon</p>
          </div>
        </div>

        <div className="p-3 border-t bg-gray-50 text-xs text-gray-500 flex justify-between">
          <span>Press Escape to close</span>
          <span>⌘K to search</span>
        </div>
      </div>
    </div>
  )
}
