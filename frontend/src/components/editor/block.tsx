'use client'

import { useState, useRef, useEffect } from 'react'
import { Block as BlockType } from '@/types'
import { TextBlock } from './blocks/text-block'
import { HeadingBlock } from './blocks/heading-block'
import { ListBlock } from './blocks/list-block'
import { TodoBlock } from './blocks/todo-block'
import { QuoteBlock } from './blocks/quote-block'
import { CodeBlock } from './blocks/code-block'
import { DividerBlock } from './blocks/divider-block'
import { ImageBlock } from './blocks/image-block'
import { DatabaseBlock } from './blocks/database-block'
import { Button } from '@/components/ui/button'
import { GripVertical, Plus, Trash2 } from 'lucide-react'

interface BlockProps {
  block: BlockType
  dragHandleProps?: any
  onUpdate: (content: any) => void
  onDelete: () => void
  onAddBlock: (type: string) => void
  onSlashMenu: (show: boolean, position: { x: number; y: number }) => void
}

export function Block({
  block,
  dragHandleProps,
  onUpdate,
  onDelete,
  onAddBlock,
  onSlashMenu
}: BlockProps) {
  const [isHovered, setIsHovered] = useState(false)
  const [showActions, setShowActions] = useState(false)
  const blockRef = useRef<HTMLDivElement>(null)

  const handleKeyDown = (e: KeyboardEvent) => {
    if (e.key === '/') {
      const rect = blockRef.current?.getBoundingClientRect()
      if (rect) {
        onSlashMenu(true, { x: rect.left, y: rect.bottom })
      }
    }
  }

  const renderBlock = () => {
    switch (block.type) {
      case 'TEXT':
        return (
          <TextBlock
            content={block.content}
            onChange={onUpdate}
            onKeyDown={handleKeyDown}
          />
        )
      case 'HEADING_1':
      case 'HEADING_2':
      case 'HEADING_3':
        return (
          <HeadingBlock
            level={parseInt(block.type.split('_')[1])}
            content={block.content}
            onChange={onUpdate}
            onKeyDown={handleKeyDown}
          />
        )
      case 'BULLET_LIST':
      case 'NUMBERED_LIST':
        return (
          <ListBlock
            type={block.type}
            content={block.content}
            onChange={onUpdate}
            onKeyDown={handleKeyDown}
          />
        )
      case 'TODO':
        return (
          <TodoBlock
            content={block.content}
            onChange={onUpdate}
            onKeyDown={handleKeyDown}
          />
        )
      case 'QUOTE':
        return (
          <QuoteBlock
            content={block.content}
            onChange={onUpdate}
            onKeyDown={handleKeyDown}
          />
        )
      case 'CODE':
        return (
          <CodeBlock
            content={block.content}
            onChange={onUpdate}
          />
        )
      case 'DIVIDER':
        return <DividerBlock />
      case 'IMAGE':
        return (
          <ImageBlock
            content={block.content}
            onChange={onUpdate}
          />
        )
      case 'DATABASE':
        return (
          <DatabaseBlock
            content={block.content}
            onChange={onUpdate}
          />
        )
      default:
        return (
          <TextBlock
            content={block.content}
            onChange={onUpdate}
            onKeyDown={handleKeyDown}
          />
        )
    }
  }

  return (
    <div
      ref={blockRef}
      className="block group relative"
      onMouseEnter={() => setIsHovered(true)}
      onMouseLeave={() => setIsHovered(false)}
    >
      {/* Block Actions */}
      {isHovered && (
        <div className="absolute left-0 top-0 -ml-12 flex items-center space-x-1 opacity-0 group-hover:opacity-100 transition-opacity">
          <Button
            variant="ghost"
            size="sm"
            className="h-6 w-6 p-0 cursor-grab"
            {...dragHandleProps}
          >
            <GripVertical className="h-3 w-3" />
          </Button>
          <Button
            variant="ghost"
            size="sm"
            className="h-6 w-6 p-0"
            onClick={() => setShowActions(!showActions)}
          >
            <Plus className="h-3 w-3" />
          </Button>
        </div>
      )}

      {/* Block Content */}
      <div className="min-h-[1.5rem]">
        {renderBlock()}
      </div>

      {/* Quick Actions */}
      {showActions && (
        <div className="absolute left-0 top-full mt-1 bg-white border rounded-md shadow-lg p-2 z-10">
          <div className="grid grid-cols-3 gap-1">
            <Button
              variant="ghost"
              size="sm"
              onClick={() => onAddBlock('TEXT')}
            >
              Text
            </Button>
            <Button
              variant="ghost"
              size="sm"
              onClick={() => onAddBlock('HEADING_1')}
            >
              H1
            </Button>
            <Button
              variant="ghost"
              size="sm"
              onClick={() => onAddBlock('BULLET_LIST')}
            >
              List
            </Button>
            <Button
              variant="ghost"
              size="sm"
              onClick={() => onAddBlock('TODO')}
            >
              Todo
            </Button>
            <Button
              variant="ghost"
              size="sm"
              onClick={() => onAddBlock('IMAGE')}
            >
              Image
            </Button>
            <Button
              variant="ghost"
              size="sm"
              className="text-red-600"
              onClick={onDelete}
            >
              <Trash2 className="h-3 w-3" />
            </Button>
          </div>
        </div>
      )}
    </div>
  )
}
