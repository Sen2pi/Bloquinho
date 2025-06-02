'use client'

import { useState, useEffect } from 'react'
import { Button } from '@/components/ui/button'
import { Plus, Trash2 } from 'lucide-react'
import { cn } from '@/lib/utils'

interface ListBlockProps {
  type: 'BULLET_LIST' | 'NUMBERED_LIST'
  content: { items: string[] }
  onChange: (content: { items: string[] }) => void
  onKeyDown?: (e: KeyboardEvent) => void
}

export function ListBlock({ 
  type, 
  content, 
  onChange, 
  onKeyDown 
}: ListBlockProps) {
  const [items, setItems] = useState(content.items || [''])

  useEffect(() => {
    setItems(content.items || [''])
  }, [content.items])

  const updateItem = (index: number, value: string) => {
    const newItems = [...items]
    newItems[index] = value
    setItems(newItems)
    onChange({ items: newItems })
  }

  const addItem = () => {
    const newItems = [...items, '']
    setItems(newItems)
    onChange({ items: newItems })
  }

  const removeItem = (index: number) => {
    if (items.length > 1) {
      const newItems = items.filter((_, i) => i !== index)
      setItems(newItems)
      onChange({ items: newItems })
    }
  }

  const handleKeyDown = (e: React.KeyboardEvent, index: number) => {
    if (e.key === 'Enter') {
      e.preventDefault()
      addItem()
    } else if (e.key === 'Backspace' && items[index] === '' && items.length > 1) {
      e.preventDefault()
      removeItem(index)
    } else if (onKeyDown && e.key === '/') {
      onKeyDown(e.nativeEvent)
    }
  }

  return (
    <div className="space-y-2">
      {items.map((item, index) => (
        <div key={index} className="flex items-start space-x-2 group">
          <div className="flex-shrink-0 w-6 h-6 flex items-center justify-center mt-1">
            {type === 'BULLET_LIST' ? (
              <div className="w-1.5 h-1.5 bg-gray-400 rounded-full" />
            ) : (
              <span className="text-sm text-gray-600">{index + 1}.</span>
            )}
          </div>
          
          <input
            type="text"
            value={item}
            onChange={(e) => updateItem(index, e.target.value)}
            onKeyDown={(e) => handleKeyDown(e, index)}
            placeholder="List item"
            className="flex-1 border-none outline-none bg-transparent placeholder:text-gray-400"
          />
          
          <div className="opacity-0 group-hover:opacity-100 transition-opacity flex space-x-1">
            <Button
              variant="ghost"
              size="sm"
              onClick={addItem}
              className="h-6 w-6 p-0"
            >
              <Plus className="h-3 w-3" />
            </Button>
            {items.length > 1 && (
              <Button
                variant="ghost"
                size="sm"
                onClick={() => removeItem(index)}
                className="h-6 w-6 p-0 text-red-500"
              >
                <Trash2 className="h-3 w-3" />
              </Button>
            )}
          </div>
        </div>
      ))}
    </div>
  )
}
