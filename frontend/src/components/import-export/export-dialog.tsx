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
import { Download, FileText, File, FileSpreadsheet, Upload } from 'lucide-react'
import axios from 'axios'
import toast from 'react-hot-toast'
import { jsPDF } from 'jspdf'
import html2canvas from 'html2canvas'

interface ExportManagerProps {
  pageId: string
  pageTitle: string
  pageContent: any[]
}

export function ExportManager({ pageId, pageTitle, pageContent }: ExportManagerProps) {
  const [isExporting, setIsExporting] = useState(false)
  const [isImporting, setIsImporting] = useState(false)

  // Exportar para PDF
  const exportToPDF = async () => {
    setIsExporting(true)
    try {
      const element = document.getElementById('page-content')
      if (!element) throw new Error('Page content not found')

      const canvas = await html2canvas(element, {
        scale: 2,
        useCORS: true,
        logging: false
      })

      const imgData = canvas.toDataURL('image/png')
      const pdf = new jsPDF('p', 'mm', 'a4')
      
      const imgWidth = 210
      const pageHeight = 295
      const imgHeight = (canvas.height * imgWidth) / canvas.width
      let heightLeft = imgHeight

      let position = 0

      pdf.addImage(imgData, 'PNG', 0, position, imgWidth, imgHeight)
      heightLeft -= pageHeight

      while (heightLeft >= 0) {
        position = heightLeft - imgHeight
        pdf.addPage()
        pdf.addImage(imgData, 'PNG', 0, position, imgWidth, imgHeight)
        heightLeft -= pageHeight
      }

      pdf.save(`${pageTitle}.pdf`)
      toast.success('PDF exported successfully!')
    } catch (error) {
      console.error('PDF export failed:', error)
      toast.error('Failed to export PDF')
    } finally {
      setIsExporting(false)
    }
  }

  // Exportar para Markdown
  const exportToMarkdown = () => {
    setIsExporting(true)
    try {
      let markdown = `# ${pageTitle}\n\n`
      
      pageContent.forEach(block => {
        switch (block.type) {
          case 'HEADING_1':
            markdown += `# ${block.content.text}\n\n`
            break
          case 'HEADING_2':
            markdown += `## ${block.content.text}\n\n`
            break
          case 'HEADING_3':
            markdown += `### ${block.content.text}\n\n`
            break
          case 'TEXT':
            markdown += `${block.content.text}\n\n`
            break
          case 'BULLET_LIST':
            block.content.items.forEach((item: string) => {
              markdown += `- ${item}\n`
            })
            markdown += '\n'
            break
          case 'NUMBERED_LIST':
            block.content.items.forEach((item: string, index: number) => {
              markdown += `${index + 1}. ${item}\n`
            })
            markdown += '\n'
            break
          case 'QUOTE':
            markdown += `> ${block.content.text}\n\n`
            break
          case 'CODE':
            markdown += `\`\`\`${block.content.language || ''}\n${block.content.text}\n\`\`\`\n\n`
            break
          case 'DIVIDER':
            markdown += '---\n\n'
            break
          default:
            if (block.content.text) {
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
      console.error('Markdown export failed:', error)
      toast.error('Failed to export Markdown')
    } finally {
      setIsExporting(false)
    }
  }

  // Exportar para Word
  const exportToWord = async () => {
    setIsExporting(true)
    try {
      const response = await axios.post(`/api/pages/${pageId}/export/word`, {
        title: pageTitle,
        content: pageContent
      }, {
        responseType: 'blob'
      })

      const blob = new Blob([response.data], { 
        type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' 
      })
      const url = URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = `${pageTitle}.docx`
      a.click()
      URL.revokeObjectURL(url)

      toast.success('Word document exported successfully!')
    } catch (error) {
      console.error('Word export failed:', error)
      toast.error('Failed to export Word document')
    } finally {
      setIsExporting(false)
    }
  }

  // Importar Markdown
  const importMarkdown = (file: File) => {
    setIsImporting(true)
    const reader = new FileReader()
    
    reader.onload = async (e) => {
      try {
        const markdown = e.target?.result as string
        
        // Converter Markdown para blocos
        const blocks = parseMarkdownToBlocks(markdown)
        
        // Enviar para o backend
        await axios.post(`/api/pages/${pageId}/import`, {
          blocks,
          type: 'markdown'
        })

        toast.success('Markdown imported successfully!')
        window.location.reload() // Recarregar para mostrar novo conteúdo
      } catch (error) {
        console.error('Markdown import failed:', error)
        toast.error('Failed to import Markdown')
      } finally {
        setIsImporting(false)
      }
    }
    
    reader.readAsText(file)
  }

  // Parser Markdown para Blocos
  const parseMarkdownToBlocks = (markdown: string) => {
    const lines = markdown.split('\n')
    const blocks: any[] = []
    
    let currentList: string[] = []
    let currentListType: 'BULLET_LIST' | 'NUMBERED_LIST' | null = null
    let codeBlock = false
    let codeContent = ''
    let codeLanguage = ''

    const flushList = () => {
      if (currentList.length > 0 && currentListType) {
        blocks.push({
          type: currentListType,
          content: { items: currentList },
          order: blocks.length
        })
        currentList = []
        currentListType = null
      }
    }

    lines.forEach(line => {
      const trimmed = line.trim()
      
      if (trimmed.startsWith('```')) {
        if (codeBlock) {
          // End code block
          blocks.push({
            type: 'CODE',
            content: { text: codeContent, language: codeLanguage },
            order: blocks.length
          })
          codeBlock = false
          codeContent = ''
          codeLanguage = ''
        } else {
          // Start code block
          flushList()
          codeBlock = true
          codeLanguage = trimmed.substring(3)
        }
        return
      }

      if (codeBlock) {
        codeContent += line + '\n'
        return
      }

      if (trimmed.startsWith('# ')) {
        flushList()
        blocks.push({
          type: 'HEADING_1',
          content: { text: trimmed.substring(2) },
          order: blocks.length
        })
      } else if (trimmed.startsWith('## ')) {
        flushList()
        blocks.push({
          type: 'HEADING_2',
          content: { text: trimmed.substring(3) },
          order: blocks.length
        })
      } else if (trimmed.startsWith('### ')) {
        flushList()
        blocks.push({
          type: 'HEADING_3',
          content: { text: trimmed.substring(4) },
          order: blocks.length
        })
      } else if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
        if (currentListType !== 'BULLET_LIST') {
          flushList()
          currentListType = 'BULLET_LIST'
        }
        currentList.push(trimmed.substring(2))
      } else if (/^\d+\.\s/.test(trimmed)) {
        if (currentListType !== 'NUMBERED_LIST') {
          flushList()
          currentListType = 'NUMBERED_LIST'
        }
        currentList.push(trimmed.replace(/^\d+\.\s/, ''))
      } else if (trimmed.startsWith('> ')) {
        flushList()
        blocks.push({
          type: 'QUOTE',
          content: { text: trimmed.substring(2) },
          order: blocks.length
        })
      } else if (trimmed === '---') {
        flushList()
        blocks.push({
          type: 'DIVIDER',
          content: {},
          order: blocks.length
        })
      } else if (trimmed && !trimmed.startsWith('#')) {
        flushList()
        blocks.push({
          type: 'TEXT',
          content: { text: trimmed },
          order: blocks.length
        })
      }
    })

    flushList()
    return blocks
  }

  const handleFileUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (file && file.type === 'text/markdown') {
      importMarkdown(file)
    } else {
      toast.error('Please select a Markdown file (.md)')
    }
  }

  return (
    <div className="flex items-center space-x-2">
      {/* Export */}
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
              Choose a format to export "{pageTitle}"
            </DialogDescription>
          </DialogHeader>

          <div className="space-y-3">
            <Button
              onClick={exportToPDF}
              disabled={isExporting}
              className="w-full justify-start h-auto p-4"
              variant="outline"
            >
              <File className="h-8 w-8 text-red-500 mr-3" />
              <div className="text-left">
                <h3 className="font-medium">PDF</h3>
                <p className="text-sm text-gray-500">Perfect for sharing and printing</p>
              </div>
            </Button>

            <Button
              onClick={exportToMarkdown}
              disabled={isExporting}
              className="w-full justify-start h-auto p-4"
              variant="outline"
            >
              <FileText className="h-8 w-8 text-blue-500 mr-3" />
              <div className="text-left">
                <h3 className="font-medium">Markdown</h3>
                <p className="text-sm text-gray-500">Plain text format for developers</p>
              </div>
            </Button>

            <Button
              onClick={exportToWord}
              disabled={isExporting}
              className="w-full justify-start h-auto p-4"
              variant="outline"
            >
              <FileSpreadsheet className="h-8 w-8 text-blue-600 mr-3" />
              <div className="text-left">
                <h3 className="font-medium">Word Document</h3>
                <p className="text-sm text-gray-500">Compatible with Microsoft Word</p>
              </div>
            </Button>
          </div>
        </DialogContent>
      </Dialog>

      {/* Import */}
      <Dialog>
        <DialogTrigger asChild>
          <Button variant="outline" size="sm">
            <Upload className="h-4 w-4 mr-2" />
            Import
          </Button>
        </DialogTrigger>
        
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Import Content</DialogTitle>
            <DialogDescription>
              Import content from Markdown files
            </DialogDescription>
          </DialogHeader>

          <div className="space-y-4">
            <div className="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center">
              <Upload className="mx-auto h-8 w-8 text-gray-400 mb-2" />
              <p className="text-sm text-gray-600 mb-4">
                Select a Markdown file to import
              </p>
              <input
                type="file"
                accept=".md,.markdown"
                onChange={handleFileUpload}
                className="hidden"
                id="file-upload"
                disabled={isImporting}
              />
              <label htmlFor="file-upload">
                <Button variant="outline" disabled={isImporting} asChild>
                  <span>
                    {isImporting ? 'Importing...' : 'Choose File'}
                  </span>
                </Button>
              </label>
            </div>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  )
}
