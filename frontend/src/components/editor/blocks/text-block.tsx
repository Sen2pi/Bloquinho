'use client'

import { useState, useEffect } from 'react'
import { RichTextEditor } from '../rich-text-editor'

interface TextBlockProps {
  content: { text?: string }
  onChange: (content: { text: string }) => void
  placeholder?: string
  onKeyDown?: (e: KeyboardEvent) => void
}

export function TextBlock({ content, onChange, placeholder = "Type something...", onKeyDown }: TextBlockProps) {
  const handleChange = (text: string) => {
    onChange({ text })
  }

  return (
    <div className="w-full">
      <RichTextEditor
        content={content.text || ''}
        onChange={handleChange}
        placeholder={placeholder}
        showToolbar={true}
      />
    </div>
  )
}
