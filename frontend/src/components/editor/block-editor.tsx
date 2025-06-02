'use client'

import { useEffect, useState } from 'react'
import { DragDropContext, Droppable, Draggable } from 'react-beautiful-dnd'
import { useBlockStore } from '@/lib/stores/block'
import { Block } from '@/components/editor/block'
import { SlashMenu } from '@/components/editor/slash-menu'
import { Button } from '@/components/ui/button'
import { Plus } from 'lucide-react'

interface BlockEditorProps {
  pageId: string
}

export function BlockEditor({ pageId }: BlockEditorProps) {
  const { blocks, fetchBlocks, createBlock, updateBlock, deleteBlock, reorderBlocks } = useBlockStore()
  const [showSlashMenu, setShowSlashMenu] = useState(false)
  const [slashMenuPosition, setSlashMenuPosition] = useState({ x: 0, y: 0 })
  const [activeBlockId, setActiveBlockId] = useState<string | null>(null)

  useEffect(() => {
    fetchBlocks(pageId)
  }, [pageId, fetchBlocks])

  const handleDragEnd = (result: any) => {
    if (!result.destination) return

    const newBlocks = Array.from(blocks)
    const [reorderedBlock] = newBlocks.splice(result.source.index, 1)
    newBlocks.splice(result.destination.index, 0, reorderedBlock)

    const updates = newBlocks.map((block, index) => ({
      id: block.id,
      order: index
    }))

    reorderBlocks(updates)
  }

  const handleAddBlock = (type: string, afterBlockId?: string) => {
    const afterIndex = afterBlockId 
      ? blocks.findIndex(b => b.id === afterBlockId)
      : blocks.length - 1

    createBlock({
      type,
      content: getDefaultContent(type),
      pageId,
      order: afterIndex + 1
    })
  }

  const getDefaultContent = (type: string) => {
    switch (type) {
      case 'TEXT':
        return { text: '' }
      case 'HEADING_1':
        return { text: 'Heading 1' }
      case 'HEADING_2':
        return { text: 'Heading 2' }
      case 'HEADING_3':
        return { text: 'Heading 3' }
      case 'BULLET_LIST':
        return { items: [''] }
      case 'NUMBERED_LIST':
        return { items: [''] }
      case 'TODO':
        return { text: '', checked: false }
      case 'QUOTE':
        return { text: '' }
      case 'CODE':
        return { text: '', language: 'javascript' }
      case 'DIVIDER':
        return {}
      default:
        return { text: '' }
    }
  }

  return (
    <div className="space-y-2">
      <DragDropContext onDragEnd={handleDragEnd}>
        <Droppable droppableId="blocks">
          {(provided) => (
            <div {...provided.droppableProps} ref={provided.innerRef}>
              {blocks.map((block, index) => (
                <Draggable key={block.id} draggableId={block.id} index={index}>
                  {(provided, snapshot) => (
                    <div
                      ref={provided.innerRef}
                      {...provided.draggableProps}
                      className={`group relative ${
                        snapshot.isDragging ? 'opacity-50' : ''
                      }`}
                    >
                      <Block
                        block={block}
                        dragHandleProps={provided.dragHandleProps}
                        onUpdate={(content) => updateBlock(block.id, { content })}
                        onDelete={() => deleteBlock(block.id)}
                        onAddBlock={(type) => handleAddBlock(type, block.id)}
                        onSlashMenu={(show, position) => {
                          setShowSlashMenu(show)
                          setSlashMenuPosition(position)
                          setActiveBlockId(block.id)
                        }}
                      />
                    </div>
                  )}
                </Draggable>
              ))}
              {provided.placeholder}
            </div>
          )}
        </Droppable>
      </DragDropContext>

      {blocks.length === 0 && (
        <div className="text-center py-12">
          <p className="text-gray-500 mb-4">Start writing or press / for commands</p>
          <Button onClick={() => handleAddBlock('TEXT')}>
            <Plus className="h-4 w-4 mr-2" />
            Add a block
          </Button>
        </div>
      )}

      {showSlashMenu && (
        <SlashMenu
          position={slashMenuPosition}
          onSelect={(type) => {
            handleAddBlock(type, activeBlockId || undefined)
            setShowSlashMenu(false)
          }}
          onClose={() => setShowSlashMenu(false)}
        />
      )}
    </div>
  )
}
