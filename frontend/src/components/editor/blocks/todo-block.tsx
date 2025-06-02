'use client'

import { useState, useEffect } from 'react'
import { Checkbox } from '@/components/ui/checkbox'
import { cn } from '@/lib/utils'

interface TodoBlockProps {
  content: { text: string; checked: boolean }
  onChange: (content: { text: string; checked: boolean }) => void
  onKeyDown?: (e: KeyboardEvent) => void
}

export function TodoBlock({ 
  content, 
  onChange, 
  onKeyDown 
}: TodoBlockProps) {
  const [text, setText] = useState(content.text || '')
  const [checked, setChecked] = useState(content.checked || false)

  useEffect(() => {
    setText(content.text || '')
    setChecked(content.checked || false)
  }, [content])

  const handleTextChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const newText = e.target.value
    setText(newText)
    onChange({ text: newText, checked })
  }

  const handleCheckedChange = (newChecked: boolean) => {
    setChecked(newChecked)
    onChange({ text, checked: newChecked })
  }

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (onKeyDown && e.key === '/') {
      onKeyDown(e.nativeEvent)
    }
  }

  return (
    <div className="flex items-center space-x-3">
      <Checkbox
        checked={checked}
        onCheckedChange={handleCheckedChange}
        className="mt-0.5"
      />
      <input
        type="text"
        value={text}
        onChange={handleTextChange}
        onKeyDown={handleKeyDown}
        placeholder="To-do"
        className={cn(
          "flex-1 border-none outline-none bg-transparent placeholder:text-gray-400",
          checked && "line-through text-gray-500"
        )}
      />
    </div>
  )
}
