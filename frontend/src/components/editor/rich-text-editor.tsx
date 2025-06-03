'use client'

import { useEditor, EditorContent } from '@tiptap/react'
import StarterKit from '@tiptap/starter-kit'
import TextStyle from '@tiptap/extension-text-style'
import Color from '@tiptap/extension-color'
import Highlight from '@tiptap/extension-highlight'
import Placeholder from '@tiptap/extension-placeholder'
import { Button } from '@/components/ui/button'
import {
  Bold,
  Italic,
  Underline,
  Strikethrough,
  Code,
  Palette,
  Highlighter,
  AlignLeft,
  AlignCenter,
  AlignRight,
  List,
  ListOrdered,
  Link,
  Quote
} from 'lucide-react'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
import { useState } from 'react'

interface RichTextEditorProps {
  content: string
  onChange: (content: string) => void
  placeholder?: string
  showToolbar?: boolean
}

const textColors = [
  { name: 'Default', value: 'inherit' },
  { name: 'Gray', value: '#6B7280' },
  { name: 'Brown', value: '#92400E' },
  { name: 'Orange', value: '#EA580C' },
  { name: 'Yellow', value: '#CA8A04' },
  { name: 'Green', value: '#16A34A' },
  { name: 'Blue', value: '#2563EB' },
  { name: 'Purple', value: '#9333EA' },
  { name: 'Pink', value: '#DB2777' },
  { name: 'Red', value: '#DC2626' }
]

const backgroundColors = [
  { name: 'Default', value: 'transparent' },
  { name: 'Gray', value: '#F3F4F6' },
  { name: 'Brown', value: '#FEF3C7' },
  { name: 'Orange', value: '#FED7AA' },
  { name: 'Yellow', value: '#FEF08A' },
  { name: 'Green', value: '#DCFCE7' },
  { name: 'Blue', value: '#DBEAFE' },
  { name: 'Purple', value: '#E9D5FF' },
  { name: 'Pink', value: '#FCE7F3' },
  { name: 'Red', value: '#FEE2E2' }
]

export function RichTextEditor({ 
  content, 
  onChange, 
  placeholder = "Type something...",
  showToolbar = true 
}: RichTextEditorProps) {
  const [isLinkModalOpen, setIsLinkModalOpen] = useState(false)

  const editor = useEditor({
    extensions: [
      StarterKit.configure({
        bulletList: {
          keepMarks: true,
          keepAttributes: false,
        },
        orderedList: {
          keepMarks: true,
          keepAttributes: false,
        },
      }),
      TextStyle,
      Color.configure({ types: ['textStyle'] }),
      Highlight.configure({
        multicolor: true,
      }),
      Placeholder.configure({
        placeholder,
      }),
    ],
    content,
    onUpdate: ({ editor }) => {
      onChange(editor.getHTML())
    },
    editorProps: {
      attributes: {
        class: 'prose prose-sm sm:prose lg:prose-lg xl:prose-2xl mx-auto focus:outline-none min-h-[60px] p-3',
      },
    },
  })

  if (!editor) {
    return null
  }

  const addLink = () => {
    const url = window.prompt('Enter URL:')
    if (url) {
      editor.chain().focus().extendMarkRange('link').setLink({ href: url }).run()
    }
  }

  return (
    <div className="border rounded-lg bg-white">
      {/* Toolbar */}
      {showToolbar && (
        <div className="border-b p-2 flex items-center space-x-1 flex-wrap bg-gray-50">
          {/* Formatação Básica */}
          <div className="flex items-center space-x-1 mr-2">
            <Button
              variant={editor.isActive('bold') ? 'default' : 'ghost'}
              size="sm"
              onClick={() => editor.chain().focus().toggleBold().run()}
              className="h-8 w-8 p-0"
            >
              <Bold className="h-4 w-4" />
            </Button>
            
            <Button
              variant={editor.isActive('italic') ? 'default' : 'ghost'}
              size="sm"
              onClick={() => editor.chain().focus().toggleItalic().run()}
              className="h-8 w-8 p-0"
            >
              <Italic className="h-4 w-4" />
            </Button>
            
            <Button
              variant={editor.isActive('strike') ? 'default' : 'ghost'}
              size="sm"
              onClick={() => editor.chain().focus().toggleStrike().run()}
              className="h-8 w-8 p-0"
            >
              <Strikethrough className="h-4 w-4" />
            </Button>
            
            <Button
              variant={editor.isActive('code') ? 'default' : 'ghost'}
              size="sm"
              onClick={() => editor.chain().focus().toggleCode().run()}
              className="h-8 w-8 p-0"
            >
              <Code className="h-4 w-4" />
            </Button>
          </div>

          <div className="w-px h-6 bg-gray-300" />

          {/* Cor do Texto */}
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="ghost" size="sm" className="h-8 w-8 p-0">
                <Palette className="h-4 w-4" />
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent className="w-64">
              <div className="p-3">
                <p className="text-xs font-medium mb-2">Text Color</p>
                <div className="grid grid-cols-5 gap-1">
                  {textColors.map((color) => (
                    <button
                      key={color.name}
                      className="w-8 h-8 rounded border border-gray-200 flex items-center justify-center hover:scale-110 transition-transform"
                      style={{ backgroundColor: color.value === 'inherit' ? '#ffffff' : color.value }}
                      onClick={() => {
                        if (color.value === 'inherit') {
                          editor.chain().focus().unsetColor().run()
                        } else {
                          editor.chain().focus().setColor(color.value).run()
                        }
                      }}
                      title={color.name}
                    >
                      {color.value === 'inherit' && <span className="text-xs">A</span>}
                    </button>
                  ))}
                </div>
              </div>
            </DropdownMenuContent>
          </DropdownMenu>

          {/* Cor de Fundo */}
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="ghost" size="sm" className="h-8 w-8 p-0">
                <Highlighter className="h-4 w-4" />
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent className="w-64">
              <div className="p-3">
                <p className="text-xs font-medium mb-2">Background Color</p>
                <div className="grid grid-cols-5 gap-1">
                  {backgroundColors.map((color) => (
                    <button
                      key={color.name}
                      className="w-8 h-8 rounded border border-gray-200 flex items-center justify-center hover:scale-110 transition-transform"
                      style={{ backgroundColor: color.value }}
                      onClick={() => {
                        if (color.value === 'transparent') {
                          editor.chain().focus().unsetHighlight().run()
                        } else {
                          editor.chain().focus().setHighlight({ color: color.value }).run()
                        }
                      }}
                      title={color.name}
                    >
                      {color.value === 'transparent' && <span className="text-xs">×</span>}
                    </button>
                  ))}
                </div>
              </div>
            </DropdownMenuContent>
          </DropdownMenu>

          <div className="w-px h-6 bg-gray-300" />

          {/* Listas */}
          <Button
            variant={editor.isActive('bulletList') ? 'default' : 'ghost'}
            size="sm"
            onClick={() => editor.chain().focus().toggleBulletList().run()}
            className="h-8 w-8 p-0"
          >
            <List className="h-4 w-4" />
          </Button>

          <Button
            variant={editor.isActive('orderedList') ? 'default' : 'ghost'}
            size="sm"
            onClick={() => editor.chain().focus().toggleOrderedList().run()}
            className="h-8 w-8 p-0"
          >
            <ListOrdered className="h-4 w-4" />
          </Button>

          <Button
            variant={editor.isActive('blockquote') ? 'default' : 'ghost'}
            size="sm"
            onClick={() => editor.chain().focus().toggleBlockquote().run()}
            className="h-8 w-8 p-0"
          >
            <Quote className="h-4 w-4" />
          </Button>

          <div className="w-px h-6 bg-gray-300" />

          {/* Link */}
          <Button
            variant="ghost"
            size="sm"
            onClick={addLink}
            className="h-8 w-8 p-0"
          >
            <Link className="h-4 w-4" />
          </Button>
        </div>
      )}

      {/* Editor */}
      <div className="min-h-[60px]">
        <EditorContent editor={editor} />
      </div>
    </div>
  )
}
