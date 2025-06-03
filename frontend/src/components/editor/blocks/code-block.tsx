'use client'

import { useState, useRef, useEffect } from 'react'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Button } from '@/components/ui/button'
import { Copy, Check } from 'lucide-react'
import { cn } from '@/lib/utils'

interface CodeBlockProps {
  content: { text: string; language?: string }
  onChange: (content: { text: string; language?: string }) => void
}

const languages = [
  { value: 'javascript', label: 'JavaScript' },
  { value: 'typescript', label: 'TypeScript' },
  { value: 'python', label: 'Python' },
  { value: 'java', label: 'Java' },
  { value: 'cpp', label: 'C++' },
  { value: 'csharp', label: 'C#' },
  { value: 'php', label: 'PHP' },
  { value: 'ruby', label: 'Ruby' },
  { value: 'go', label: 'Go' },
  { value: 'rust', label: 'Rust' },
  { value: 'swift', label: 'Swift' },
  { value: 'kotlin', label: 'Kotlin' },
  { value: 'css', label: 'CSS' },
  { value: 'html', label: 'HTML' },
  { value: 'sql', label: 'SQL' },
  { value: 'json', label: 'JSON' },
  { value: 'yaml', label: 'YAML' },
  { value: 'bash', label: 'Bash' },
  { value: 'powershell', label: 'PowerShell' },
  { value: 'dockerfile', label: 'Dockerfile' },
  { value: 'markdown', label: 'Markdown' },
  { value: 'plaintext', label: 'Plain Text' }
]

export function CodeBlock({ content, onChange }: CodeBlockProps) {
  const [text, setText] = useState(content.text || '')
  const [language, setLanguage] = useState(content.language || 'javascript')
  const [copied, setCopied] = useState(false)
  const [isEditing, setIsEditing] = useState(false)
  const textareaRef = useRef<HTMLTextAreaElement>(null)
  const codeRef = useRef<HTMLElement>(null)

  useEffect(() => {
    setText(content.text || '')
    setLanguage(content.language || 'javascript')
  }, [content])

  useEffect(() => {
    if (codeRef.current && !isEditing && text && typeof window !== 'undefined') {
      codeRef.current.textContent = text
      // @ts-ignore
      if (window.hljs && language !== 'plaintext') {
        // @ts-ignore
        window.hljs.highlightElement(codeRef.current)
      }
    }
  }, [text, language, isEditing])

  const handleTextChange = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
    const newText = e.target.value
    setText(newText)
    onChange({ text: newText, language })
  }

  const handleLanguageChange = (newLanguage: string) => {
    setLanguage(newLanguage)
    onChange({ text, language: newLanguage })
  }

  const handleCopy = async () => {
    try {
      await navigator.clipboard.writeText(text)
      setCopied(true)
      setTimeout(() => setCopied(false), 2000)
    } catch (error) {
      console.error('Failed to copy:', error)
    }
  }

  const handleDoubleClick = () => {
    setIsEditing(true)
  }

  const handleBlur = () => {
    setIsEditing(false)
  }

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Escape') {
      setIsEditing(false)
    }
    if (e.key === 'Tab') {
      e.preventDefault()
      const textarea = e.target as HTMLTextAreaElement
      const start = textarea.selectionStart
      const end = textarea.selectionEnd
      const newText = text.substring(0, start) + '  ' + text.substring(end)
      setText(newText)
      onChange({ text: newText, language })
      
      setTimeout(() => {
        textarea.selectionStart = textarea.selectionEnd = start + 2
      }, 0)
    }
  }

  return (
    <div className="border rounded-lg bg-gray-900 overflow-hidden">
      {/* Header */}
      <div className="flex items-center justify-between px-4 py-2 bg-gray-800 border-b border-gray-700">
        <Select value={language} onValueChange={handleLanguageChange}>
          <SelectTrigger className="w-48 h-8 bg-gray-700 border-gray-600 text-white">
            <SelectValue />
          </SelectTrigger>
          <SelectContent>
            {languages.map((lang) => (
              <SelectItem key={lang.value} value={lang.value}>
                {lang.label}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
        
        <div className="flex items-center space-x-2">
          <Button
            variant="ghost"
            size="sm"
            onClick={handleCopy}
            className="h-8 text-gray-300 hover:text-white hover:bg-gray-700"
          >
            {copied ? (
              <Check className="h-4 w-4" />
            ) : (
              <Copy className="h-4 w-4" />
            )}
          </Button>
        </div>
      </div>
      
      {/* Code Content */}
      <div className="relative">
        {isEditing ? (
          <textarea
            ref={textareaRef}
            value={text}
            onChange={handleTextChange}
            onBlur={handleBlur}
            onKeyDown={handleKeyDown}
            placeholder="Enter your code..."
            className={cn(
              "w-full resize-none border-none outline-none bg-gray-900 text-white p-4",
              "font-mono text-sm leading-relaxed",
              "placeholder:text-gray-500"
            )}
            rows={Math.max(3, text.split('\n').length)}
            autoFocus
          />
        ) : (
          <pre 
            className="p-4 m-0 bg-gray-900 overflow-x-auto"
            onDoubleClick={handleDoubleClick}
          >
            <code
              ref={codeRef}
              className={`language-${language} text-sm`}
            >
              {text || 'Double-click to edit code...'}
            </code>
          </pre>
        )}
      </div>
    </div>
  )
}
