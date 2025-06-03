'use client'

import { useState, useCallback } from 'react'
import { Button } from '@/components/ui/button'
import { Plus, Columns2, Columns3, Columns4, Grid } from 'lucide-react'
import { Block } from './block'

interface NotionGridProps {
  pageId: string
  blocks: any[]
  onUpdateBlocks: (blocks: any[]) => void
  onAddBlock: (type: string, afterBlockId?: string) => void
  onUpdateBlock: (blockId: string, content: any) => void
  onDeleteBlock: (blockId: string) => void
}

export function NotionGrid({ 
  pageId, 
  blocks, 
  onUpdateBlocks, 
  onAddBlock, 
  onUpdateBlock, 
  onDeleteBlock 
}: NotionGridProps) {
  const [columnMode, setColumnMode] = useState<1 | 2 | 3 | 4>(2)

  const addNewBlock = (type: string) => {
    onAddBlock(type)
  }

  const getGridCols = () => {
    switch (columnMode) {
      case 1: return 'grid-cols-1'
      case 2: return 'grid-cols-2'
      case 3: return 'grid-cols-3'
      case 4: return 'grid-cols-4'
      default: return 'grid-cols-2'
    }
  }

  return (
    <div className="w-full">
      {/* Layout Controls */}
      <div className="flex items-center justify-between mb-6 p-4 bg-white border rounded-lg shadow-sm">
        <div className="flex items-center space-x-4">
          <span className="text-sm font-medium text-gray-700">Columns:</span>
          
          <div className="flex space-x-1 bg-gray-100 rounded-lg p-1">
            <Button
              variant={columnMode === 1 ? "default" : "ghost"}
              size="sm"
              onClick={() => setColumnMode(1)}
              className="h-8"
            >
              <Grid className="h-4 w-4" />
            </Button>
            <Button
              variant={columnMode === 2 ? "default" : "ghost"}
              size="sm"
              onClick={() => setColumnMode(2)}
              className="h-8"
            >
              <Columns2 className="h-4 w-4" />
            </Button>
            <Button
              variant={columnMode === 3 ? "default" : "ghost"}
              size="sm"
              onClick={() => setColumnMode(3)}
              className="h-8"
            >
              <Columns3 className="h-4 w-4" />
            </Button>
            <Button
              variant={columnMode === 4 ? "default" : "ghost"}
              size="sm"
              onClick={() => setColumnMode(4)}
              className="h-8"
            >
              <Columns4 className="h-4 w-4" />
            </Button>
          </div>
        </div>

        <div className="flex space-x-2">
          <Button size="sm" onClick={() => addNewBlock('TEXT')}>
            <Plus className="h-4 w-4 mr-2" />
            Text
          </Button>
          <Button variant="outline" size="sm" onClick={() => addNewBlock('TABLE')}>
            Table
          </Button>
          <Button variant="outline" size="sm" onClick={() => addNewBlock('CODE')}>
            Code
          </Button>
        </div>
      </div>

      {/* Grid Layout */}
      <div className={`grid ${getGridCols()} gap-4 min-h-[400px]`}>
        {blocks.map((block) => (
          <div key={block.id} className="bg-white border rounded-lg shadow-sm overflow-hidden hover:shadow-md transition-shadow">
            <Block
              block={block}
              onUpdate={(content) => onUpdateBlock(block.id, content)}
              onDelete={() => onDeleteBlock(block.id)}
              onAddBlock={onAddBlock}
              onSlashMenu={() => {}}
              isInGrid={true}
            />
          </div>
        ))}
      </div>

      {blocks.length === 0 && (
        <div className="text-center py-20 border-2 border-dashed border-gray-300 rounded-lg">
          <Grid className="mx-auto h-12 w-12 text-gray-400 mb-4" />
          <h3 className="text-lg font-medium text-gray-900 mb-2">Start building your page</h3>
          <p className="text-gray-500 mb-6">Add blocks to create your content layout</p>
          <div className="flex justify-center space-x-2">
            <Button onClick={() => addNewBlock('TEXT')}>
              <Plus className="h-4 w-4 mr-2" />
              Add Text
            </Button>
            <Button variant="outline" onClick={() => addNewBlock('TABLE')}>
              Add Table
            </Button>
          </div>
        </div>
      )}
    </div>
  )
}
