'use client'

import { useState, useEffect } from 'react'
import { Input } from '@/components/ui/input'

interface HeadingBlockProps {
  level: 1 | 2 | 3
  content: { text?: string }
  onChange: (content: { text: string }) => void
  onKeyDown?: (e: KeyboardEvent) => void
}

export function HeadingBlock({ level, content, onChange, onKeyDown }: HeadingBlockProps) {
  const [text, setText] = useState(content.text || '')

  useEffect(() => {
    setText(content.text || '')
  }, [content.text])

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const newText = e.target.value
    setText(newText)
    onChange({ text: newText })
  }

  const getClassName = () => {
    switch (level) {
      case 1: return 'text-3xl font-bold'
      case 2: return 'text-2xl font-semibold'
      case 3: return 'text-xl font-medium'
      default: return 'text-xl font-medium'
    }
  }

  return (
    <Input
      value={text}
      onChange={handleChange}
      placeholder={`Heading ${level}`}
      className={`border-none shadow-none p-0 h-auto bg-transparent ${getClassName()}`}
    />
  )
}
