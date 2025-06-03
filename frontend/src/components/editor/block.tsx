'use client'

import { useState, useRef, useEffect } from 'react'
import { TextBlock } from './blocks/text-block'
import { HeadingBlock } from './blocks/heading-block'
import { ListBlock } from './blocks/list-block'
import { TodoBlock } from './blocks/todo-block'
import { QuoteBlock } from './blocks/quote-block'
import { CodeBlock } from './blocks/code-block'
import { DividerBlock } from './blocks/divider-block'
import { ImageBlock } from './blocks/image-block'
import { DatabaseBlock } from './blocks/database-block'
import { TableBlock } from './blocks/table-block'
import { PageBlock } from './blocks/page-block'
import { Button } from '@/components/ui/button'
import { GripVertical, Plus, Trash2, MoreHorizontal } from 'lucide-react'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'

interface BlockProps {
  block: any
  dragHandleProps?: any
  onUpdate: (content: any) => void
  onDelete: () => void
  onAddBlock: (type: string) => void
  onSlashMenu: (show: boolean, position?: { x: number; y: number }) => void
  isInGrid?: boolean
}

export function Block({
  block,
  dragHandleProps,
  onUpdate,
  onDelete,
  onAddBlock,
  onSlashMenu,
  isInGrid = false
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

  useEffect(() => {
    const element = blockRef.current
    if (element) {
      element.addEventListener('keydown', handleKeyDown)
      return () => element.removeEventListener('keydown', handleKeyDown)
    }
  }, [])

  const renderBlock = () => {
    switch (block.type) {
      case 'TEXT':
        return (
          <TextBlock
            content={block.content}
            onChange={onUpdate}
            onKeyDown={handleKeyDown}
            placeholder="Type '/' for commands"
          />
        )

      case 'HEADING_1':
      case 'HEADING_2':
      case 'HEADING_3':
        return (
          <HeadingBlock
            level={parseInt(block.type.split('_')[1]) as 1 | 2 | 3}
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

      case 'TABLE':
        return (
          <TableBlock
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

      case 'PAGE':
        return (
          <PageBlock
            content={block.content}
            onChange={onUpdate}
            parentPageId={block.pageId}
          />
        )

      default:
        return (
          <TextBlock
            content={block.content}
            onChange={onUpdate}
            onKeyDown={handleKeyDown}
            placeholder="Type '/' for commands"
          />
        )
    }
  }

  return (
    <div 
      ref={blockRef}
      className={`block group relative transition-all duration-200 ${
        isInGrid ? 'h-full p-2' : 'my-1 min-h-[2rem]'
      }`}
      onMouseEnter={() => setIsHovered(true)}
      onMouseLeave={() => setIsHovered(false)}
    >
      {/* Block Actions */}
      {isHovered && !isInGrid && (
        <div className="absolute -left-10 top-0 flex items-center space-x-1 opacity-0 group-hover:opacity-100 transition-opacity">
          <div {...dragHandleProps} className="cursor-grab">
            <GripVertical className="h-4 w-4 text-gray-400 hover:text-gray-600" />
          </div>
          
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button
                variant="ghost"
                size="sm"
                className="h-6 w-6 p-0"
                onClick={() => setShowActions(!showActions)}
              >
                <Plus className="h-3 w-3" />
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent>
              <DropdownMenuItem onClick={() => onAddBlock('TEXT')}>
                Text
              </DropdownMenuItem>
              <DropdownMenuItem onClick={() => onAddBlock('HEADING_1')}>
                Heading 1
              </DropdownMenuItem>
              <DropdownMenuItem onClick={() => onAddBlock('BULLET_LIST')}>
                Bullet List
              </DropdownMenuItem>
              <DropdownMenuItem onClick={() => onAddBlock('TODO')}>
                To-do
              </DropdownMenuItem>
              <DropdownMenuSeparator />
              <DropdownMenuItem onClick={() => onAddBlock('TABLE')}>
                Table
              </DropdownMenuItem>
              <DropdownMenuItem onClick={() => onAddBlock('PAGE')}>
                Sub-page
              </DropdownMenuItem>
              <DropdownMenuItem onClick={() => onAddBlock('IMAGE')}>
                Image
              </DropdownMenuItem>
              <DropdownMenuSeparator />
              <DropdownMenuItem onClick={onDelete} className="text-red-600">
                <Trash2 className="h-3 w-3 mr-2" />
                Delete
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      )}

      {/* Block Content */}
      <div className={isInGrid ? 'h-full overflow-hidden' : ''}>
        {renderBlock()}
      </div>
    </div>
  )
}
