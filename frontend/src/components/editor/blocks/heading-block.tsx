'use client'

import { useState, useRef, useEffect } from 'react'
import { cn } from '@/lib/utils'

interface HeadingBlockProps {
  level: 1 | 2 | 3
  content: { text: string }
  onChange: (content: { text: string }) => void
  onKeyDown?: (e: KeyboardEvent) => void
}

export function HeadingBlock({ 
  level, 
  content, 
  onChange, 
  onKeyDown 
}: HeadingBlockProps) {
  const [text, setText] = useState(content.text || '')
  const inputRef = useRef<HTMLInputElement>(null)

  useEffect(() => {
    setText(content.text || '')
  }, [content.text])

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const newText = e.target.value
    setText(newText)
    onChange({ text: newText })
  }

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (onKeyDown && e.key === '/') {
      onKeyDown(e.nativeEvent)
    }
  }

  const getHeadingClasses = () => {
    switch (level) {
      case 1:
        return "text-3xl font-bold"
      case 2:
        return "text-2xl font-semibold"
      case 3:
        return "text-xl font-medium"
      default:
        return "text-xl font-medium"
    }
  }

  return (
    <input
      ref={inputRef}
      type="text"
      value={text}
      onChange={handleChange}
      onKeyDown={handleKeyDown}
      placeholder={`Heading ${level}`}
      className={cn(
        "w-full border-none outline-none bg-transparent",
        "placeholder:text-gray-400",
        getHeadingClasses()
      )}
    />
  )
}
