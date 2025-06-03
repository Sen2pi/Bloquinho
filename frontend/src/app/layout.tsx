import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'
import { Toaster } from 'react-hot-toast'
import Script from 'next/script'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'NotionClone - Your Personal Workspace',
  description: 'A powerful, self-hosted alternative to Notion',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <head>
        <link 
          rel="stylesheet" 
          href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/vs2015.min.css" 
        />
      </head>
      <body className={inter.className}>
        {children}
        <Toaster position="bottom-right" />
        
        <Script 
          src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js"
          strategy="beforeInteractive"
        />
        <Script id="hljs-init" strategy="afterInteractive">
          {`
            if (typeof hljs !== 'undefined') {
              hljs.highlightAll();
            }
          `}
        </Script>
      </body>
    </html>
  )
}
