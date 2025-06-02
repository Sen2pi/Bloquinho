'use client'

import { useState, useEffect } from 'react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Plus, Settings, Trash2 } from 'lucide-react'
import { useDatabaseStore } from '@/lib/stores/database'

interface DatabaseBlockProps {
  content: { databaseId?: string }
  onChange: (content: { databaseId?: string }) => void
}

export function DatabaseBlock({ content, onChange }: DatabaseBlockProps) {
  const { databases, currentDatabase, fetchDatabase, createDatabase, updateDatabase } = useDatabaseStore()
  const [isCreating, setIsCreating] = useState(!content.databaseId)
  const [name, setName] = useState('')

  useEffect(() => {
    if (content.databaseId) {
      fetchDatabase(content.databaseId)
    }
  }, [content.databaseId, fetchDatabase])

  const handleCreateDatabase = async () => {
    if (name.trim()) {
      try {
        const database = await createDatabase({
          name: name.trim(),
          properties: {
            'Name': { type: 'title' },
            'Status': { type: 'select', options: ['Not Started', 'In Progress', 'Completed'] },
            'Created': { type: 'created_time' }
          }
        })
        onChange({ databaseId: database.id })
        setIsCreating(false)
      } catch (error) {
        console.error('Failed to create database:', error)
      }
    }
  }

  if (isCreating) {
    return (
      <div className="border rounded-lg p-4 space-y-4">
        <h3 className="font-medium">Create Database</h3>
        <div className="flex space-x-2">
          <Input
            placeholder="Database name"
            value={name}
            onChange={(e) => setName(e.target.value)}
            onKeyDown={(e) => e.key === 'Enter' && handleCreateDatabase()}
          />
          <Button onClick={handleCreateDatabase} disabled={!name.trim()}>
            Create
          </Button>
        </div>
      </div>
    )
  }

  if (!currentDatabase) {
    return (
      <div className="border rounded-lg p-4">
        <div className="text-center text-gray-500">Loading database...</div>
      </div>
    )
  }

  return (
    <div className="border rounded-lg overflow-hidden">
      <div className="bg-gray-50 px-4 py-3 border-b flex items-center justify-between">
        <h3 className="font-medium">{currentDatabase.name}</h3>
        <div className="flex space-x-2">
          <Button variant="ghost" size="sm">
            <Settings className="h-4 w-4" />
          </Button>
          <Button variant="ghost" size="sm">
            <Plus className="h-4 w-4" />
          </Button>
        </div>
      </div>
      
      <div className="overflow-x-auto">
        <table className="w-full">
          <thead className="bg-gray-50 border-b">
            <tr>
              {Object.entries(currentDatabase.properties || {}).map(([key, property]) => (
                <th key={key} className="px-4 py-2 text-left text-sm font-medium text-gray-700">
                  {key}
                </th>
              ))}
              <th className="w-10"></th>
            </tr>
          </thead>
          <tbody>
            {currentDatabase.rows?.map((row, index) => (
              <tr key={row.id} className="border-b hover:bg-gray-50">
                {Object.entries(currentDatabase.properties || {}).map(([key, property]) => (
                  <td key={key} className="px-4 py-2">
                    <DatabaseCell
                      value={row.data[key]}
                      property={property}
                      onChange={(value) => {
                        // Update row data
                        const newData = { ...row.data, [key]: value }
                        // updateDatabaseRow(row.id, newData)
                      }}
                    />
                  </td>
                ))}
                <td className="px-4 py-2">
                  <Button variant="ghost" size="sm" className="text-red-500">
                    <Trash2 className="h-3 w-3" />
                  </Button>
                </td>
              </tr>
            ))}
            <tr className="border-b">
              <td colSpan={Object.keys(currentDatabase.properties || {}).length + 1} className="px-4 py-2">
                <Button variant="ghost" size="sm" className="w-full justify-start text-gray-500">
                  <Plus className="h-4 w-4 mr-2" />
                  New row
                </Button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  )
}

function DatabaseCell({ value, property, onChange }: any) {
  switch (property.type) {
    case 'title':
      return (
        <Input
          value={value || ''}
          onChange={(e) => onChange(e.target.value)}
          className="border-none bg-transparent"
        />
      )
    case 'select':
      return (
        <Select value={value || ''} onValueChange={onChange}>
          <SelectTrigger className="border-none bg-transparent">
            <SelectValue placeholder="Select..." />
          </SelectTrigger>
          <SelectContent>
            {property.options?.map((option: string) => (
              <SelectItem key={option} value={option}>
                {option}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
      )
    case 'created_time':
      return (
        <span className="text-sm text-gray-500">
          {value ? new Date(value).toLocaleDateString() : new Date().toLocaleDateString()}
        </span>
      )
    default:
      return (
        <Input
          value={value || ''}
          onChange={(e) => onChange(e.target.value)}
          className="border-none bg-transparent"
        />
      )
  }
}
