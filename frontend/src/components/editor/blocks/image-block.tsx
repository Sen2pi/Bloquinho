'use client'

import { useState, useRef } from 'react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Upload, Link, X } from 'lucide-react'
import { cn } from '@/lib/utils'

interface ImageBlockProps {
  content: { url?: string; alt?: string; caption?: string }
  onChange: (content: { url?: string; alt?: string; caption?: string }) => void
}

export function ImageBlock({ content, onChange }: ImageBlockProps) {
  const [showUrlInput, setShowUrlInput] = useState(!content.url)
  const [url, setUrl] = useState(content.url || '')
  const [caption, setCaption] = useState(content.caption || '')
  const fileInputRef = useRef<HTMLInputElement>(null)

  const handleUrlSubmit = () => {
    if (url) {
      onChange({ ...content, url })
      setShowUrlInput(false)
    }
  }

  const handleFileUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (file) {
      // In a real implementation, you would upload the file to your server
      // For now, we'll create a local URL
      const localUrl = URL.createObjectURL(file)
      onChange({ ...content, url: localUrl, alt: file.name })
      setShowUrlInput(false)
    }
  }

  const handleCaptionChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const newCaption = e.target.value
    setCaption(newCaption)
    onChange({ ...content, caption: newCaption })
  }

  const removeImage = () => {
    onChange({ url: '', alt: '', caption: '' })
    setShowUrlInput(true)
    setUrl('')
    setCaption('')
  }

  if (!content.url || showUrlInput) {
    return (
      <div className="border-2 border-dashed border-gray-300 rounded-lg p-6">
        <div className="text-center space-y-4">
          <div className="space-y-2">
            <Button
              variant="outline"
              onClick={() => fileInputRef.current?.click()}
              className="w-full"
            >
              <Upload className="h-4 w-4 mr-2" />
              Upload Image
            </Button>
            <input
              ref={fileInputRef}
              type="file"
              accept="image/*"
              onChange={handleFileUpload}
              className="hidden"
            />
          </div>
          
          <div className="text-sm text-gray-500">or</div>
          
          <div className="flex space-x-2">
            <Input
              type="url"
              placeholder="Paste image URL"
              value={url}
              onChange={(e) => setUrl(e.target.value)}
              onKeyDown={(e) => e.key === 'Enter' && handleUrlSubmit()}
            />
            <Button onClick={handleUrlSubmit} disabled={!url}>
              <Link className="h-4 w-4" />
            </Button>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-2">
      <div className="relative group">
        <img
          src={content.url}
          alt={content.alt || 'Image'}
          className="w-full rounded-lg shadow-sm"
        />
        <Button
          variant="destructive"
          size="sm"
          onClick={removeImage}
          className="absolute top-2 right-2 opacity-0 group-hover:opacity-100 transition-opacity"
        >
          <X className="h-4 w-4" />
        </Button>
      </div>
      
      <Input
        type="text"
        placeholder="Add a caption..."
        value={caption}
        onChange={handleCaptionChange}
        className="text-sm text-gray-600 border-none bg-transparent"
      />
    </div>
  )
}
