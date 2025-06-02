'use client'

import { useState, useEffect } from 'react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Textarea } from '@/components/ui/textarea'
import { Card, CardContent, CardHeader } from '@/components/ui/card'
import { X, Send, MessageSquare, User } from 'lucide-react'
import { useAuthStore } from '@/lib/stores/auth'
import axios from 'axios'
import toast from 'react-hot-toast'

interface Comment {
  id: string
  content: string
  createdAt: string
  creator: {
    id: string
    name: string
    email: string
    avatar?: string
  }
}

interface CommentsSidebarProps {
  pageId: string
  onClose: () => void
}

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001'

export function CommentsSidebar({ pageId, onClose }: CommentsSidebarProps) {
  const { user } = useAuthStore()
  const [comments, setComments] = useState<Comment[]>([])
  const [newComment, setNewComment] = useState('')
  const [isLoading, setIsLoading] = useState(false)
  const [isSubmitting, setIsSubmitting] = useState(false)

  useEffect(() => {
    fetchComments()
  }, [pageId])

  const fetchComments = async () => {
    setIsLoading(true)
    try {
      const response = await axios.get(`${API_URL}/api/comments/page/${pageId}`)
      setComments(response.data)
    } catch (error) {
      console.error('Failed to fetch comments:', error)
      toast.error('Failed to load comments')
    } finally {
      setIsLoading(false)
    }
  }

  const handleSubmitComment = async (e: React.FormEvent) => {
    e.preventDefault()
    
    if (!newComment.trim()) return

    setIsSubmitting(true)
    try {
      const response = await axios.post(`${API_URL}/api/comments`, {
        content: newComment.trim(),
        pageId
      })

      setComments([response.data, ...comments])
      setNewComment('')
      toast.success('Comment added!')
    } catch (error) {
      console.error('Failed to add comment:', error)
      toast.error('Failed to add comment')
    } finally {
      setIsSubmitting(false)
    }
  }

  const formatDate = (date: string) => {
    return new Intl.DateTimeFormat('pt-PT', {
      day: '2-digit',
      month: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    }).format(new Date(date))
  }

  return (
    <div className="w-80 bg-white border-l h-full flex flex-col">
      {/* Header */}
      <div className="p-4 border-b flex items-center justify-between">
        <div className="flex items-center space-x-2">
          <MessageSquare className="h-5 w-5 text-purple-600" />
          <h3 className="font-semibold">Comments</h3>
          <span className="text-sm text-gray-500">({comments.length})</span>
        </div>
        <Button variant="ghost" size="sm" onClick={onClose}>
          <X className="h-4 w-4" />
        </Button>
      </div>

      {/* Comments List */}
      <div className="flex-1 overflow-y-auto p-4 space-y-4">
        {isLoading ? (
          <div className="space-y-4">
            {[...Array(3)].map((_, i) => (
              <Card key={i} className="animate-pulse">
                <CardHeader className="pb-2">
                  <div className="h-4 bg-gray-200 rounded w-1/2"></div>
                </CardHeader>
                <CardContent>
                  <div className="space-y-2">
                    <div className="h-3 bg-gray-200 rounded"></div>
                    <div className="h-3 bg-gray-200 rounded w-3/4"></div>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        ) : comments.length === 0 ? (
          <div className="text-center py-8">
            <MessageSquare className="mx-auto h-12 w-12 text-gray-400 mb-4" />
            <p className="text-gray-500">No comments yet</p>
            <p className="text-sm text-gray-400">Be the first to leave a comment!</p>
          </div>
        ) : (
          comments.map((comment) => (
            <Card key={comment.id} className="shadow-sm">
              <CardHeader className="pb-2">
                <div className="flex items-center space-x-2">
                  <div className="w-6 h-6 bg-purple-100 rounded-full flex items-center justify-center">
                    <User className="h-3 w-3 text-purple-600" />
                  </div>
                  <div className="flex-1">
                    <div className="flex items-center justify-between">
                      <span className="text-sm font-medium">{comment.creator.name}</span>
                      <span className="text-xs text-gray-500">
                        {formatDate(comment.createdAt)}
                      </span>
                    </div>
                  </div>
                </div>
              </CardHeader>
              <CardContent>
                <p className="text-sm text-gray-700 leading-relaxed">
                  {comment.content}
                </p>
              </CardContent>
            </Card>
          ))
        )}
      </div>

      {/* New Comment Form */}
      <div className="p-4 border-t bg-gray-50">
        <form onSubmit={handleSubmitComment} className="space-y-3">
          <Textarea
            placeholder="Add a comment..."
            value={newComment}
            onChange={(e) => setNewComment(e.target.value)}
            rows={3}
            className="resize-none"
          />
          <div className="flex justify-end">
            <Button 
              type="submit" 
              size="sm"
              disabled={!newComment.trim() || isSubmitting}
              className="bg-purple-600 hover:bg-purple-700"
            >
              {isSubmitting ? (
                <div className="flex items-center space-x-2">
                  <div className="animate-spin rounded-full h-3 w-3 border-b-2 border-white"></div>
                  <span>Posting...</span>
                </div>
              ) : (
                <>
                  <Send className="h-3 w-3 mr-2" />
                  Post
                </>
              )}
            </Button>
          </div>
        </form>
      </div>
    </div>
  )
}
