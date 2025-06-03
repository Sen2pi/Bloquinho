'use client'

import { useState } from 'react'
import { Button } from '@/components/ui/button'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog'
import { Download, FileText, File, Upload } from 'lucide-react'
import toast from 'react-hot-toast'

interface ExportManagerProps {
  pageId: string
  pageTitle: string
  pageContent?: any[]
}

export function ExportManager({ pageId, pageTitle, pageContent = [] }: ExportManagerProps) {
  const [isExporting, setIsExporting] = useState(false)

  const exportToMarkdown = () => {
    setIsExporting(true)
    try {
      let markdown = `# ${pageTitle}\n\n`
      
      // Simular conversão dos blocos para markdown
      pageContent.forEach(block => {
        switch (block.type) {
          case 'HEADING_1':
            markdown += `# ${block.content?.text || ''}\n\n`
            break
          case 'HEADING_2':
            markdown += `## ${block.content?.text || ''}\n\n`
            break
          case 'HEADING_3':
            markdown += `### ${block.content?.text || ''}\n\n`
            break
          case 'TEXT':
            markdown += `${block.content?.text || ''}\n\n`
            break
          case 'CODE':
            markdown += `\`\`\`${block.content?.language || ''}\n${block.content?.text || ''}\n\`\`\`\n\n`
            break
          default:
            if (block.content?.text) {
              markdown += `${block.content.text}\n\n`
            }
        }
      })

      const blob = new Blob([markdown], { type: 'text/markdown' })
      const url = URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = `${pageTitle}.md`
      a.click()
      URL.revokeObjectURL(url)

      toast.success('Markdown exported successfully!')
    } catch (error) {
      console.error('Export failed:', error)
      toast.error('Failed to export')
    } finally {
      setIsExporting(false)
    }
  }

  return (
    <Dialog>
      <DialogTrigger asChild>
        <Button variant="outline" size="sm">
          <Download className="h-4 w-4 mr-2" />
          Export
        </Button>
      </DialogTrigger>
      
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Export Page</DialogTitle>
          <DialogDescription>
            Export "{pageTitle}" in different formats
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-3">
          <Button
            onClick={exportToMarkdown}
            disabled={isExporting}
            className="w-full justify-start h-auto p-4"
            variant="outline"
          >
            <FileText className="h-8 w-8 text-blue-500 mr-3" />
            <div className="text-left">
              <h3 className="font-medium">Markdown</h3>
              <p className="text-sm text-gray-500">Plain text format</p>
            </div>
          </Button>
        </div>
      </DialogContent>
    </Dialog>
  )
}
