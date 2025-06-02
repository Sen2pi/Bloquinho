'use client'

import { useState, useRef, useEffect } from 'react'
import { cn } from '@/lib/utils'

interface TextBlockProps {
  content: { text: string }
  onChange: (content: { text: string }) => void
  onKeyDown?: (e: KeyboardEvent) => void
  placeholder?: string
}

export function TextBlock({ 
  content, 
  onChange, 
  onKeyDown, 
  placeholder = "Type '/' for commands" 
}: TextBlockProps) {
  const [text, setText] = useState(content.text || '')
  const textareaRef = useRef<HTMLTextAreaElement>(null)

  useEffect(() => {
    setText(content.text || '')
  }, [content.text])

  useEffect(() => {
    if (textareaRef.current) {
      textareaRef.current.style.height = 'auto'
      textareaRef.current.style.height = textareaRef.current.scrollHeight + 'px'
    }
  }, [text])

  const handleChange = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
    const newText = e.target.value
    setText(newText)
    onChange({ text: newText })
  }

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (onKeyDown && e.key === '/') {
      onKeyDown(e.nativeEvent)
    }
  }

  return (
    <textarea
      ref={textareaRef}
      value={text}
      onChange={handleChange}
      onKeyDown={handleKeyDown}
      placeholder={placeholder}
      className={cn(
        "w-full resize-none border-none outline-none bg-transparent",
        "text-base leading-relaxed",
        "placeholder:text-gray-400"
      )}
      rows={1}
    />
  )
}
