'use client'

import { useState, useEffect } from 'react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { BarChart, Bar, LineChart, Line, PieChart, Pie, Cell, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts'
import { Plus, Trash2, BarChart3, LineChart as LineChartIcon, PieChart as PieChartIcon } from 'lucide-react'

interface ChartData {
  type: 'bar' | 'line' | 'pie'
  title: string
  data: Array<{ name: string; value: number; [key: string]: any }>
  colors: string[]
}

interface ChartBlockProps {
  content: { chartData: ChartData }
  onChange: (content: { chartData: ChartData }) => void
}

const defaultColors = ['#8884d8', '#82ca9d', '#ffc658', '#ff7c7c', '#8dd1e1']

export function ChartBlock({ content, onChange }: ChartBlockProps) {
  const [chartData, setChartData] = useState<ChartData>(
    content.chartData || {
      type: 'bar',
      title: 'Chart Title',
      data: [
        { name: 'Jan', value: 400 },
        { name: 'Feb', value: 300 },
        { name: 'Mar', value: 500 },
        { name: 'Apr', value: 280 },
        { name: 'May', value: 590 }
      ],
      colors: defaultColors
    }
  )

  const [isEditing, setIsEditing] = useState(false)

  useEffect(() => {
    onChange({ chartData })
  }, [chartData, onChange])

  const updateDataPoint = (index: number, field: 'name' | 'value', value: string | number) => {
    const newData = [...chartData.data]
    newData[index] = { ...newData[index], [field]: value }
    setChartData({ ...chartData, data: newData })
  }

  const addDataPoint = () => {
    const newData = [...chartData.data, { name: `Item ${chartData.data.length + 1}`, value: 0 }]
    setChartData({ ...chartData, data: newData })
  }

  const removeDataPoint = (index: number) => {
    if (chartData.data.length <= 1) return
    const newData = chartData.data.filter((_, i) => i !== index)
    setChartData({ ...chartData, data: newData })
  }

  const renderChart = () => {
    switch (chartData.type) {
      case 'bar':
        return (
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={chartData.data}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="name" />
              <YAxis />
              <Tooltip />
              <Legend />
              <Bar dataKey="value" fill={chartData.colors[0]} />
            </BarChart>
          </ResponsiveContainer>
        )
      
      case 'line':
        return (
          <ResponsiveContainer width="100%" height={300}>
            <LineChart data={chartData.data}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="name" />
              <YAxis />
              <Tooltip />
              <Legend />
              <Line type="monotone" dataKey="value" stroke={chartData.colors[0]} strokeWidth={2} />
            </LineChart>
          </ResponsiveContainer>
        )
      
      case 'pie':
        return (
          <ResponsiveContainer width="100%" height={300}>
            <PieChart>
              <Pie
                data={chartData.data}
                cx="50%"
                cy="50%"
                labelLine={false}
                label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}
                outerRadius={80}
                fill="#8884d8"
                dataKey="value"
              >
                {chartData.data.map((entry, index) => (
                  <Cell key={`cell-${index}`} fill={chartData.colors[index % chartData.colors.length]} />
                ))}
              </Pie>
              <Tooltip />
            </PieChart>
          </ResponsiveContainer>
        )
      
      default:
        return null
    }
  }

  return (
    <div className="border rounded-lg p-4 bg-white">
      {/* Header */}
      <div className="flex items-center justify-between mb-4">
        <Input
          value={chartData.title}
          onChange={(e) => setChartData({ ...chartData, title: e.target.value })}
          className="text-lg font-semibold border-none shadow-none p-0 bg-transparent"
        />
        
        <div className="flex items-center space-x-2">
          <Select
            value={chartData.type}
            onValueChange={(value: 'bar' | 'line' | 'pie') => 
              setChartData({ ...chartData, type: value })
            }
          >
            <SelectTrigger className="w-32">
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="bar">
                <div className="flex items-center">
                  <BarChart3 className="h-4 w-4 mr-2" />
                  Bar
                </div>
              </SelectItem>
              <SelectItem value="line">
                <div className="flex items-center">
                  <LineChartIcon className="h-4 w-4 mr-2" />
                  Line
                </div>
              </SelectItem>
              <SelectItem value="pie">
                <div className="flex items-center">
                  <PieChartIcon className="h-4 w-4 mr-2" />
                  Pie
                </div>
              </SelectItem>
            </SelectContent>
          </Select>
          
          <Button
            variant="outline"
            size="sm"
            onClick={() => setIsEditing(!isEditing)}
          >
            {isEditing ? 'Done' : 'Edit Data'}
          </Button>
        </div>
      </div>

      {/* Chart */}
      <div className="mb-4">
        {renderChart()}
      </div>

      {/* Data Editor */}
      {isEditing && (
        <div className="space-y-4 border-t pt-4">
          <h4 className="font-medium">Chart Data</h4>
          
          <div className="space-y-2">
            {chartData.data.map((item, index) => (
              <div key={index} className="flex items-center space-x-2">
                <Input
                  value={item.name}
                  onChange={(e) => updateDataPoint(index, 'name', e.target.value)}
                  placeholder="Label"
                  className="flex-1"
                />
                <Input
                  type="number"
                  value={item.value}
                  onChange={(e) => updateDataPoint(index, 'value', parseFloat(e.target.value) || 0)}
                  placeholder="Value"
                  className="w-24"
                />
                <Button
                  variant="ghost"
                  size="sm"
                  onClick={() => removeDataPoint(index)}
                  className="text-red-500"
                >
                  <Trash2 className="h-4 w-4" />
                </Button>
              </div>
            ))}
          </div>
          
          <Button
            variant="outline"
            size="sm"
            onClick={addDataPoint}
            className="w-full"
          >
            <Plus className="h-4 w-4 mr-2" />
            Add Data Point
          </Button>
        </div>
      )}
    </div>
  )
}
