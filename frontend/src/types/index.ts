export interface User {
  id: string
  email: string
  name: string
  avatar?: string
  createdAt: string
  updatedAt: string
}

export interface Workspace {
  id: string
  name: string
  description?: string
  icon?: string
  createdAt: string
  updatedAt: string
  members: WorkspaceMember[]
  _count: {
    pages: number
  }
}

export interface WorkspaceMember {
  id: string
  userId: string
  workspaceId: string
  role: 'OWNER' | 'ADMIN' | 'MEMBER' | 'VIEWER'
  user: User
}

export interface Page {
  id: string
  title: string
  icon?: string
  cover?: string
  parentId?: string
  workspaceId: string
  createdBy: string
  createdAt: string
  updatedAt: string
  creator: User
  children?: Page[]
  blocks?: Block[]
  workspace?: Workspace
}

export interface Block {
  id: string
  type: BlockType
  content: any
  parentId?: string
  pageId: string
  order: number
  createdBy: string
  createdAt: string
  updatedAt: string
  creator: User
  children?: Block[]
}

export type BlockType = 
  | 'TEXT'
  | 'HEADING_1'
  | 'HEADING_2' 
  | 'HEADING_3'
  | 'BULLET_LIST'
  | 'NUMBERED_LIST'
  | 'TODO'
  | 'TOGGLE'
  | 'QUOTE'
  | 'DIVIDER'
  | 'IMAGE'
  | 'VIDEO'
  | 'AUDIO'
  | 'FILE'
  | 'CODE'
  | 'TABLE'
  | 'DATABASE'
  | 'EMBED'
  | 'BOOKMARK'

export interface Comment {
  id: string
  content: string
  pageId: string
  createdBy: string
  createdAt: string
  updatedAt: string
  creator: User
}

export interface Database {
  id: string
  name: string
  description?: string
  properties: Record<string, DatabaseProperty>
  createdAt: string
  updatedAt: string
  rows?: DatabaseRow[]
}

export interface DatabaseRow {
  id: string
  databaseId: string
  data: Record<string, any>
  createdAt: string
  updatedAt: string
}

export interface DatabaseProperty {
  type: 'title' | 'text' | 'number' | 'select' | 'multi_select' | 'date' | 'person' | 'file' | 'checkbox' | 'url' | 'email' | 'phone' | 'formula' | 'relation' | 'rollup' | 'created_time' | 'created_by' | 'last_edited_time' | 'last_edited_by'
  options?: string[]
  format?: string
}

export interface Template {
  id: string
  name: string
  description: string
  category: string
  blocks: Partial<Block>[]
}

export interface BackupConfig {
  provider: 'onedrive' | 'googledrive' | 'webdav'
  schedule: 'daily' | 'weekly' | 'monthly'
  retention: number
  settings: Record<string, any>
}
