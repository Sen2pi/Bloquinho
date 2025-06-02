import { useEffect, useRef } from 'react'
import { io, Socket } from 'socket.io-client'
import { useAuthStore } from '@/lib/stores/auth'
import { useBlockStore } from '@/lib/stores/block'
import toast from 'react-hot-toast'

export function useCollaboration(pageId: string) {
  const socketRef = useRef<Socket | null>(null)
  const { token } = useAuthStore()
  const { updateBlock } = useBlockStore()

  useEffect(() => {
    if (!token || !pageId) return

    // Initialize socket connection
    socketRef.current = io(process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001', {
      auth: { token }
    })

    const socket = socketRef.current

    // Join page room
    socket.emit('join-page', pageId)

    // Listen for real-time events
    socket.on('user-joined', (data) => {
      toast(`${data.userName} joined the page`, { icon: '👋' })
    })

    socket.on('user-left', (data) => {
      toast(`${data.userName} left the page`, { icon: '👋' })
    })

    socket.on('block-updated', (data) => {
      // Update block in store without triggering API call
      updateBlock(data.blockId, { content: data.content, type: data.type })
    })

    socket.on('cursor-moved', (data) => {
      // Handle cursor position updates
      showCollaboratorCursor(data)
    })

    socket.on('comment-added', (data) => {
      toast(`New comment from ${data.author.name}`, { icon: '💬' })
    })

    return () => {
      socket.emit('leave-page', pageId)
      socket.disconnect()
    }
  }, [token, pageId, updateBlock])

  const emitBlockUpdate = (blockId: string, content: any, type: string) => {
    if (socketRef.current) {
      socketRef.current.emit('block-update', {
        pageId,
        blockId,
        content,
        type
      })
    }
  }

  const emitCursorPosition = (blockId: string, position: number) => {
    if (socketRef.current) {
      socketRef.current.emit('cursor-position', {
        pageId,
        blockId,
        position
      })
    }
  }

  const showCollaboratorCursor = (data: any) => {
    // Implementation for showing collaborator cursors
    // This would create visual indicators of where other users are editing
  }

  return {
    emitBlockUpdate,
    emitCursorPosition
  }
}
