'use client'

import { useEffect, useState } from 'react'
import { useBlockStore } from '@/lib/stores/block'
import { BlockEditor } from './block-editor'
import { NotionGrid } from './notion-grid'
import { Button } from '@/components/ui/button'
import { Grid, List, Plus } from 'lucide-react'
import toast from 'react-hot-toast'

interface MainEditorProps {
  pageId: string
}

export function MainEditor({ pageId }: MainEditorProps) {
  const { blocks, fetchBlocks, createBlock } = useBlockStore()
  const [viewMode, setViewMode] = useState<'grid' | 'list'>('list')

  useEffect(() => {
    fetchBlocks(pageId)
  }, [pageId, fetchBlocks])

  const handleAddBlock = async (type: string) => {
    try {
      await createBlock({
        type,
        content: getDefaultContent(type),
        pageId,
        order: blocks.length
      })
      toast.success('Block added!')
    } catch (error) {
      console.error('Failed to add block:', error)
      toast.error('Failed to add block')
    }
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
      case 'CODE':
        return { text: '', language: 'javascript' }
      case 'TABLE':
        return {
          data: {
            headers: [
              { id: 'col1', title: 'Column 1', type: 'text' },
              { id: 'col2', title: 'Column 2', type: 'text' }
            ],
            rows: [
              { id: 'row1', cells: { col1: '', col2: '' } }
            ],
            headerRow: true
          }
        }
      default:
        return { text: '' }
    }
  }

  return (
    <div className="w-full">
      {/* Editor Controls */}
      <div className="flex items-center justify-between mb-6 p-4 bg-white border rounded-lg shadow-sm sticky top-0 z-10">
        <div className="flex items-center space-x-4">
          <span className="text-sm font-medium text-gray-700">View:</span>
          
          <div className="flex space-x-1 bg-gray-100 rounded-lg p-1">
            <Button
              variant={viewMode === 'list' ? "default" : "ghost"}
              size="sm"
              onClick={() => setViewMode('list')}
              className="h-8"
            >
              <List className="h-4 w-4" />
            </Button>
            <Button
              variant={viewMode === 'grid' ? "default" : "ghost"}
              size="sm"
              onClick={() => setViewMode('grid')}
              className="h-8"
            >
              <Grid className="h-4 w-4" />
            </Button>
          </div>
        </div>

        <div className="flex space-x-2">
          <Button 
            size="sm" 
            onClick={() => handleAddBlock('TEXT')}
            className="bg-blue-600 hover:bg-blue-700"
          >
            <Plus className="h-4 w-4 mr-2" />
            Add Block
          </Button>
        </div>
      </div>

      {/* Editor Content */}
      <div className="min-h-[400px]">
        {viewMode === 'grid' ? (
          <div className="p-4 border-2 border-dashed border-gray-300 rounded-lg text-center">
            <Grid className="h-12 w-12 text-gray-400 mx-auto mb-4" />
            <p className="text-gray-500">Grid view coming soon</p>
            <Button 
              onClick={() => setViewMode('list')} 
              className="mt-4"
            >
              Switch to List View
            </Button>
          </div>
        ) : (
          <BlockEditor pageId={pageId} />
        )}
      </div>
    </div>
  )
}
