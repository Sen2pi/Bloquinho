'use client'

import { useState, useRef, useEffect } from 'react'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
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
  { value: 'css', label: 'CSS' },
  { value: 'html', label: 'HTML' },
  { value: 'sql', label: 'SQL' },
  { value: 'json', label: 'JSON' },
  { value: 'bash', label: 'Bash' },
  { value: 'plaintext', label: 'Plain Text' }
]

export function CodeBlock({ content, onChange }: CodeBlockProps) {
  const [text, setText] = useState(content.text || '')
  const [language, setLanguage] = useState(content.language || 'javascript')
  const textareaRef = useRef<HTMLTextAreaElement>(null)

  useEffect(() => {
    setText(content.text || '')
    setLanguage(content.language || 'javascript')
  }, [content])

  useEffect(() => {
    if (textareaRef.current) {
      textareaRef.current.style.height = 'auto'
      textareaRef.current.style.height = textareaRef.current.scrollHeight + 'px'
    }
  }, [text])

  const handleTextChange = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
    const newText = e.target.value
    setText(newText)
    onChange({ text: newText, language })
  }

  const handleLanguageChange = (newLanguage: string) => {
    setLanguage(newLanguage)
    onChange({ text, language: newLanguage })
  }

  return (
    <div className="border rounded-md bg-gray-50 overflow-hidden">
      <div className="flex items-center justify-between px-3 py-2 border-b bg-gray-100">
        <Select value={language} onValueChange={handleLanguageChange}>
          <SelectTrigger className="w-40 h-8">
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
      </div>
      
      <textarea
        ref={textareaRef}
        value={text}
        onChange={handleTextChange}
        placeholder="Enter your code..."
        className={cn(
          "w-full resize-none border-none outline-none bg-transparent p-3",
          "font-mono text-sm leading-relaxed",
          "placeholder:text-gray-400"
        )}
        rows={3}
      />
    </div>
  )
}
