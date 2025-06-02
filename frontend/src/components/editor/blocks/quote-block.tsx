'use client'

import { useState, useRef, useEffect } from 'react'
import { cn } from '@/lib/utils'

interface QuoteBlockProps {
  content: { text: string }
  onChange: (content: { text: string }) => void
  onKeyDown?: (e: KeyboardEvent) => void
}

export function QuoteBlock({ 
  content, 
  onChange, 
  onKeyDown 
}: QuoteBlockProps) {
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
    <div className="border-l-4 border-gray-300 pl-4 py-2">
      <textarea
        ref={textareaRef}
        value={text}
        onChange={handleChange}
        onKeyDown={handleKeyDown}
        placeholder="Quote"
        className={cn(
          "w-full resize-none border-none outline-none bg-transparent",
          "text-base leading-relaxed italic text-gray-700",
          "placeholder:text-gray-400"
        )}
        rows={1}
      />
    </div>
  )
}
