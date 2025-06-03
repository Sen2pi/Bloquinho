'use client'

import { useState, useRef, useEffect } from 'react'
import { DragDropContext, Droppable, Draggable } from 'react-beautiful-dnd'
import { Button } from '@/components/ui/button'
import { Plus, GripVertical, Columns2, Columns3, Columns4 } from 'lucide-react'
// Importação corrigida - usar o componente Block existente
import { Block } from '@/components/editor/block'

interface GridColumn {
  id: string
  blocks: any[]
  width: number // 1-4 (25%, 50%, 75%, 100%)
}

interface GridSystemProps {
  pageId: string
  initialBlocks: any[]
  onUpdateBlocks: (blocks: any[]) => void
}

export function GridSystem({ pageId, initialBlocks, onUpdateBlocks }: GridSystemProps) {
  const [columns, setColumns] = useState<GridColumn[]>([
    { id: 'col-1', blocks: initialBlocks, width: 4 }
  ])
  const [isDragging, setIsDragging] = useState(false)

  const handleDragEnd = (result: any) => {
    setIsDragging(false)
    
    if (!result.destination) return

    const sourceColId = result.source.droppableId
    const destColId = result.destination.droppableId
    const sourceIndex = result.source.index
    const destIndex = result.destination.index

    const newColumns = [...columns]
    const sourceCol = newColumns.find(col => col.id === sourceColId)!
    const destCol = newColumns.find(col => col.id === destColId)!

    // Move block between columns
    const [movedBlock] = sourceCol.blocks.splice(sourceIndex, 1)
    destCol.blocks.splice(destIndex, 0, movedBlock)

    setColumns(newColumns)
    
    // Update all blocks with new positions
    const allBlocks = newColumns.flatMap((col, colIndex) => 
      col.blocks.map((block, blockIndex) => ({
        ...block,
        order: colIndex * 1000 + blockIndex,
        columnId: col.id
      }))
    )
    onUpdateBlocks(allBlocks)
  }

  const addColumn = () => {
    if (columns.length >= 4) return
    
    const newColumn: GridColumn = {
      id: `col-${Date.now()}`,
      blocks: [],
      width: 1
    }
    
    // Redistribute widths
    const totalCols = columns.length + 1
    const newWidth = Math.floor(4 / totalCols)
    
    setColumns([
      ...columns.map(col => ({ ...col, width: newWidth })),
      { ...newColumn, width: newWidth }
    ])
  }

  const removeColumn = (columnId: string) => {
    if (columns.length <= 1) return
    
    const colToRemove = columns.find(col => col.id === columnId)!
    const remainingColumns = columns.filter(col => col.id !== columnId)
    
    // Move blocks from removed column to first column
    if (colToRemove.blocks.length > 0) {
      remainingColumns[0].blocks.push(...colToRemove.blocks)
    }
    
    setColumns(remainingColumns)
  }

  const getColumnWidth = (width: number) => {
    switch (width) {
      case 1: return 'w-1/4'
      case 2: return 'w-2/4'
      case 3: return 'w-3/4'
      case 4: return 'w-full'
      default: return 'w-full'
    }
  }

  return (
    <div className="space-y-4">
      {/* Column Controls */}
      <div className="flex items-center space-x-2 py-2 border-b">
        <span className="text-sm text-gray-500">Layout:</span>
        <Button
          variant="outline"
          size="sm"
          onClick={addColumn}
          disabled={columns.length >= 4}
        >
          <Plus className="h-3 w-3 mr-1" />
          Add Column
        </Button>
        
        <div className="flex space-x-1">
          <Button
            variant={columns.length === 1 ? "default" : "outline"}
            size="sm"
            onClick={() => setColumns([{ id: 'col-1', blocks: columns.flatMap(c => c.blocks), width: 4 }])}
          >
            <Columns2 className="h-3 w-3" />
          </Button>
          <Button
            variant={columns.length === 2 ? "default" : "outline"}
            size="sm"
            onClick={() => {
              const allBlocks = columns.flatMap(c => c.blocks)
              const mid = Math.ceil(allBlocks.length / 2)
              setColumns([
                { id: 'col-1', blocks: allBlocks.slice(0, mid), width: 2 },
                { id: 'col-2', blocks: allBlocks.slice(mid), width: 2 }
              ])
            }}
          >
            <Columns3 className="h-3 w-3" />
          </Button>
          <Button
            variant={columns.length === 3 ? "default" : "outline"}
            size="sm"
            onClick={() => {
              const allBlocks = columns.flatMap(c => c.blocks)
              const third = Math.ceil(allBlocks.length / 3)
              setColumns([
                { id: 'col-1', blocks: allBlocks.slice(0, third), width: 1 },
                { id: 'col-2', blocks: allBlocks.slice(third, third * 2), width: 1 },
                { id: 'col-3', blocks: allBlocks.slice(third * 2), width: 2 }
              ])
            }}
          >
            <Columns4 className="h-3 w-3" />
          </Button>
        </div>
      </div>

      {/* Grid Layout */}
      <DragDropContext onDragEnd={handleDragEnd} onDragStart={() => setIsDragging(true)}>
        <div className="flex gap-4">
          {columns.map((column) => (
            <div key={column.id} className={`${getColumnWidth(column.width)} min-h-[200px]`}>
              <div className="border-2 border-dashed border-gray-200 rounded-lg p-2 h-full">
                <div className="flex items-center justify-between mb-2">
                  <span className="text-xs text-gray-500">Column {column.id.split('-')[1]}</span>
                  {columns.length > 1 && (
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => removeColumn(column.id)}
                      className="h-6 w-6 p-0 text-red-500"
                    >
                      ×
                    </Button>
                  )}
                </div>
                
                <Droppable droppableId={column.id}>
                  {(provided, snapshot) => (
                    <div
                      {...provided.droppableProps}
                      ref={provided.innerRef}
                      className={`space-y-2 min-h-[150px] ${
                        snapshot.isDraggingOver ? 'bg-blue-50 border-blue-300' : ''
                      }`}
                    >
                      {column.blocks.map((block, index) => (
                        <Draggable key={block.id} draggableId={block.id} index={index}>
                          {(provided, snapshot) => (
                            <div
                              ref={provided.innerRef}
                              {...provided.draggableProps}
                              className={`${snapshot.isDragging ? 'opacity-50' : ''}`}
                            >
                              <div className="flex items-center">
                                <div {...provided.dragHandleProps} className="mr-2 cursor-grab">
                                  <GripVertical className="h-4 w-4 text-gray-400" />
                                </div>
                                <div className="flex-1">
                                  <Block
                                    block={block}
                                    onUpdate={(content) => {
                                      // Update block content
                                      console.log('Update block:', block.id, content)
                                    }}
                                    onDelete={() => {
                                      // Delete block
                                      console.log('Delete block:', block.id)
                                    }}
                                    onAddBlock={(type) => {
                                      // Add new block
                                      console.log('Add block:', type)
                                    }}
                                    onSlashMenu={() => {
                                      // Handle slash menu
                                    }}
                                  />
                                </div>
                              </div>
                            </div>
                          )}
                        </Draggable>
                      ))}
                      {provided.placeholder}
                    </div>
                  )}
                </Droppable>
              </div>
            </div>
          ))}
        </div>
      </DragDropContext>
    </div>
  )
}
