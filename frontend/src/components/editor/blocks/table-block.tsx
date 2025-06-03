'use client'

import { useState, useEffect, useRef } from 'react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Plus, Trash2, GripVertical, MoreHorizontal, ChevronDown, Table } from 'lucide-react'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { RichTextEditor } from '../rich-text-editor'

type ColumnType = 'text' | 'number' | 'select' | 'date' | 'checkbox'

interface TableColumn {
  id: string
  title: string
  type: ColumnType
  options?: string[] // Para tipo select
}

interface TableRow {
  id: string
  cells: Record<string, any>
}

interface TableData {
  columns: TableColumn[]
  rows: TableRow[]
  headerRow: boolean
}

interface TableBlockProps {
  content: { data?: TableData }
  onChange: (content: { data: TableData }) => void
}

export function TableBlock({ content, onChange }: TableBlockProps) {
  const [data, setData] = useState<TableData>(
    content.data || {
      columns: [
        { id: 'col1', title: 'Name', type: 'text' },
        { id: 'col2', title: 'Status', type: 'select', options: ['To Do', 'In Progress', 'Done'] },
        { id: 'col3', title: 'Date', type: 'date' }
      ],
      rows: [
        { id: 'row1', cells: { col1: '', col2: '', col3: '' } },
        { id: 'row2', cells: { col1: '', col2: '', col3: '' } }
      ],
      headerRow: true
    }
  )

  const [selectedCell, setSelectedCell] = useState<{ rowId: string; colId: string } | null>(null)
  const [editingCell, setEditingCell] = useState<{ rowId: string; colId: string } | null>(null)
  const tableRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    onChange({ data })
  }, [data, onChange])

  const updateColumn = (colId: string, updates: Partial<TableColumn>) => {
    setData(prev => ({
      ...prev,
      columns: prev.columns.map(col => 
        col.id === colId ? { ...col, ...updates } : col
      )
    }))
  }

  const updateCell = (rowId: string, colId: string, value: any) => {
    setData(prev => ({
      ...prev,
      rows: prev.rows.map(row => 
        row.id === rowId 
          ? { ...row, cells: { ...row.cells, [colId]: value } }
          : row
      )
    }))
  }

  const addColumn = (type: ColumnType = 'text') => {
    const newColId = `col_${Date.now()}`
    const newColumn: TableColumn = {
      id: newColId,
      title: `Column ${data.columns.length + 1}`,
      type,
      options: type === 'select' ? ['Option 1', 'Option 2', 'Option 3'] : undefined
    }

    setData(prev => ({
      ...prev,
      columns: [...prev.columns, newColumn],
      rows: prev.rows.map(row => ({
        ...row,
        cells: { ...row.cells, [newColId]: getDefaultValue(type) }
      }))
    }))
  }

  const removeColumn = (colId: string) => {
    if (data.columns.length <= 1) return
    
    setData(prev => ({
      ...prev,
      columns: prev.columns.filter(col => col.id !== colId),
      rows: prev.rows.map(row => {
        const { [colId]: removed, ...cells } = row.cells
        return { ...row, cells }
      })
    }))
  }

  const addRow = () => {
    const newRowId = `row_${Date.now()}`
    const newCells = data.columns.reduce((acc, col) => {
      acc[col.id] = getDefaultValue(col.type)
      return acc
    }, {} as Record<string, any>)

    setData(prev => ({
      ...prev,
      rows: [...prev.rows, { id: newRowId, cells: newCells }]
    }))
  }

  const removeRow = (rowId: string) => {
    if (data.rows.length <= 1) return
    
    setData(prev => ({
      ...prev,
      rows: prev.rows.filter(row => row.id !== rowId)
    }))
  }

  const moveColumn = (fromIndex: number, toIndex: number) => {
    const newColumns = [...data.columns]
    const [movedColumn] = newColumns.splice(fromIndex, 1)
    newColumns.splice(toIndex, 0, movedColumn)
    setData(prev => ({ ...prev, columns: newColumns }))
  }

  const getDefaultValue = (type: ColumnType) => {
    switch (type) {
      case 'number': return 0
      case 'checkbox': return false
      case 'select': return ''
      case 'date': return ''
      default: return ''
    }
  }

  const renderCellContent = (row: TableRow, column: TableColumn) => {
    const value = row.cells[column.id] || getDefaultValue(column.type)
    const isEditing = editingCell?.rowId === row.id && editingCell?.colId === column.id

    if (isEditing) {
      return renderEditableCell(row, column, value)
    }

    return renderDisplayCell(row, column, value)
  }

  const renderEditableCell = (row: TableRow, column: TableColumn, value: any) => {
    switch (column.type) {
      case 'text':
        return (
          <RichTextEditor
            content={value}
            onChange={(content) => updateCell(row.id, column.id, content)}
            showToolbar={false}
            placeholder="Type something..."
          />
        )
      
      case 'number':
        return (
          <Input
            type="number"
            value={value || ''}
            onChange={(e) => updateCell(row.id, column.id, parseFloat(e.target.value) || 0)}
            onBlur={() => setEditingCell(null)}
            className="border-none bg-transparent"
            autoFocus
          />
        )
      
      case 'select':
        return (
          <Select 
            value={value} 
            onValueChange={(newValue) => updateCell(row.id, column.id, newValue)}
          >
            <SelectTrigger className="border-none bg-transparent">
              <SelectValue placeholder="Select..." />
            </SelectTrigger>
            <SelectContent>
              {column.options?.map((option) => (
                <SelectItem key={option} value={option}>
                  {option}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        )
      
      case 'date':
        return (
          <Input
            type="date"
            value={value || ''}
            onChange={(e) => updateCell(row.id, column.id, e.target.value)}
            onBlur={() => setEditingCell(null)}
            className="border-none bg-transparent"
            autoFocus
          />
        )
      
      case 'checkbox':
        return (
          <input
            type="checkbox"
            checked={value || false}
            onChange={(e) => updateCell(row.id, column.id, e.target.checked)}
            className="ml-2"
          />
        )
      
      default:
        return (
          <Input
            value={value || ''}
            onChange={(e) => updateCell(row.id, column.id, e.target.value)}
            onBlur={() => setEditingCell(null)}
            className="border-none bg-transparent"
            autoFocus
          />
        )
    }
  }

  const renderDisplayCell = (row: TableRow, column: TableColumn, value: any) => {
    const cellClass = "min-h-[40px] p-3 cursor-pointer hover:bg-gray-50 flex items-center"
    
    const handleCellClick = () => {
      setSelectedCell({ rowId: row.id, colId: column.id })
      setEditingCell({ rowId: row.id, colId: column.id })
    }

    switch (column.type) {
      case 'checkbox':
        return (
          <div className={cellClass}>
            <input
              type="checkbox"
              checked={value || false}
              onChange={(e) => updateCell(row.id, column.id, e.target.checked)}
              className="ml-2"
            />
          </div>
        )
      
      case 'select':
        return (
          <div className={cellClass} onClick={handleCellClick}>
            {value && (
              <span className="px-2 py-1 bg-blue-100 text-blue-800 rounded-full text-sm">
                {value}
              </span>
            )}
            {!value && <span className="text-gray-400">Select...</span>}
          </div>
        )
      
      default:
        return (
          <div 
            className={cellClass} 
            onClick={handleCellClick}
            dangerouslySetInnerHTML={{ 
              __html: value || '<span class="text-gray-400">Click to edit</span>' 
            }}
          />
        )
    }
  }

  return (
    <div className="border rounded-lg overflow-hidden bg-white shadow-sm">
      {/* Table Header */}
      <div className="flex items-center justify-between p-3 bg-gray-50 border-b">
        <div className="flex items-center space-x-2">
          <Table className="h-4 w-4 text-gray-600" />
          <span className="text-sm font-medium">Table</span>
          <span className="text-xs text-gray-500">
            {data.rows.length} rows × {data.columns.length} columns
          </span>
        </div>
        
        <div className="flex items-center space-x-2">
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="outline" size="sm">
                <Plus className="h-3 w-3 mr-1" />
                Add Column
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent>
              <DropdownMenuItem onClick={() => addColumn('text')}>
                Text Column
              </DropdownMenuItem>
              <DropdownMenuItem onClick={() => addColumn('number')}>
                Number Column
              </DropdownMenuItem>
              <DropdownMenuItem onClick={() => addColumn('select')}>
                Select Column
              </DropdownMenuItem>
              <DropdownMenuItem onClick={() => addColumn('date')}>
                Date Column
              </DropdownMenuItem>
              <DropdownMenuItem onClick={() => addColumn('checkbox')}>
                Checkbox Column
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
          
          <Button variant="outline" size="sm" onClick={addRow}>
            <Plus className="h-3 w-3 mr-1" />
            Add Row
          </Button>
        </div>
      </div>

      {/* Table Content */}
      <div ref={tableRef} className="overflow-x-auto">
        <table className="w-full min-w-full">
          {/* Table Headers */}
          {data.headerRow && (
            <thead className="bg-gray-50 border-b">
              <tr>
                <th className="w-8 p-2"></th>
                {data.columns.map((column, index) => (
                  <th key={column.id} className="relative group min-w-[150px] p-0">
                    <div className="flex items-center justify-between p-3">
                      <Input
                        value={column.title}
                        onChange={(e) => updateColumn(column.id, { title: e.target.value })}
                        className="border-none bg-transparent font-medium text-center"
                      />
                      
                      <DropdownMenu>
                        <DropdownMenuTrigger asChild>
                          <Button
                            variant="ghost"
                            size="sm"
                            className="opacity-0 group-hover:opacity-100 h-6 w-6 p-0"
                          >
                            <ChevronDown className="h-3 w-3" />
                          </Button>
                        </DropdownMenuTrigger>
                        <DropdownMenuContent>
                          <DropdownMenuItem onClick={() => addColumn('text')}>
                            Insert column right
                          </DropdownMenuItem>
                          <DropdownMenuItem 
                            onClick={() => removeColumn(column.id)}
                            disabled={data.columns.length <= 1}
                          >
                            Delete column
                          </DropdownMenuItem>
                          <DropdownMenuSeparator />
                          <DropdownMenuItem 
                            onClick={() => moveColumn(index, Math.max(0, index - 1))}
                            disabled={index === 0}
                          >
                            Move left
                          </DropdownMenuItem>
                          <DropdownMenuItem 
                            onClick={() => moveColumn(index, Math.min(data.columns.length - 1, index + 1))}
                            disabled={index === data.columns.length - 1}
                          >
                            Move right
                          </DropdownMenuItem>
                        </DropdownMenuContent>
                      </DropdownMenu>
                    </div>
                  </th>
                ))}
              </tr>
            </thead>
          )}
          
          {/* Table Body */}
          <tbody>
            {data.rows.map((row, rowIndex) => (
              <tr key={row.id} className="group hover:bg-gray-50 border-b">
                <td className="w-8 p-2 text-center">
                  <DropdownMenu>
                    <DropdownMenuTrigger asChild>
                      <Button
                        variant="ghost"
                        size="sm"
                        className="opacity-0 group-hover:opacity-100 h-6 w-6 p-0"
                      >
                        <GripVertical className="h-3 w-3" />
                      </Button>
                    </DropdownMenuTrigger>
                    <DropdownMenuContent>
                      <DropdownMenuItem onClick={addRow}>
                        Insert row below
                      </DropdownMenuItem>
                      <DropdownMenuItem 
                        onClick={() => removeRow(row.id)}
                        disabled={data.rows.length <= 1}
                      >
                        Delete row
                      </DropdownMenuItem>
                    </DropdownMenuContent>
                  </DropdownMenu>
                </td>
                {data.columns.map((column) => (
                  <td key={column.id} className="border-r min-w-[150px] p-0">
                    {renderCellContent(row, column)}
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )
}
