// Wiki functionality for Bloquinho
document.addEventListener('DOMContentLoaded', function() {
  let allWikiPages = [];
  let filteredPages = [];
  
  // Search functionality
  const searchInput = document.getElementById('wiki-search');
  const wikiList = document.getElementById('wiki-list');
  const noResults = document.getElementById('no-results');
  const wikiContent = document.getElementById('wiki-content');

  // Auto-detect and load wiki pages from actual folder structure
  async function loadWikiPages() {
    try {
      // Known folders in the wiki directory
      const knownFolders = [
        '1 Guide',
        '2 Security', 
        '3 Configurations',
        '4 Tutorials'
      ];
      
      allWikiPages = [];
      
      // Scan each folder for HTML files
      for (const folder of knownFolders) {
        try {
          // Try to find HTML files in this folder
          const potentialFiles = [
            'index.html',
            'faq.html',
            '001 - security.html',
            'configuration.html',
            'tutorial.html',
            'guide.html',
            'setup.html',
            'introduction.html',
            'overview.html'
          ];
          
          for (const fileName of potentialFiles) {
            try {
              const filePath = `${folder}/${fileName}`;
              const response = await fetch(`wiki/${filePath}`, { method: 'HEAD' });
              if (response.ok) {
                const pageData = {
                  file: filePath,
                  fileName: fileName,
                  folder: folder,
                  title: extractTitleFromFileName(fileName),
                  keywords: generateKeywords(fileName, folder)
                };
                allWikiPages.push(pageData);
              }
            } catch (error) {
              // File doesn't exist in this folder, continue
              continue;
            }
          }
        } catch (error) {
          console.log(`Folder ${folder} not accessible or empty`);
        }
      }
      
      // Also try to find files directly in wiki root (for backwards compatibility)
      const rootFiles = ['001 - security.html'];
      for (const fileName of rootFiles) {
        try {
          const response = await fetch(`wiki/${fileName}`, { method: 'HEAD' });
          if (response.ok) {
            const pageData = {
              file: fileName,
              fileName: fileName, 
              folder: 'Root',
              title: extractTitleFromFileName(fileName),
              keywords: generateKeywords(fileName, 'root')
            };
            allWikiPages.push(pageData);
          }
        } catch (error) {
          continue;
        }
      }
      
      filteredPages = [...allWikiPages];
      renderWikiList();
      
      // If no pages found, show a helpful message
      if (allWikiPages.length === 0) {
        showError('No wiki pages found. Add HTML files to the wiki folders.');
      }
    } catch (error) {
      console.error('Error loading wiki pages:', error);
      showError('Failed to load wiki pages');
    }
  }
  
  
  // Extract title from filename
  function extractTitleFromFileName(filename) {
    // Handle specific known files
    const fileMap = {
      'faq.html': '❓ FAQ',
      'index.html': '📋 Overview',
      '001 - security.html': '🔒 Security & Privacy',
      'configuration.html': '⚙️ Configuration',
      'tutorial.html': '📚 Tutorial',
      'guide.html': '📖 Guide', 
      'setup.html': '🔧 Setup',
      'introduction.html': '👋 Introduction',
      'overview.html': '📋 Overview'
    };
    
    if (fileMap[filename]) {
      return fileMap[filename];
    }
    
    // Handle numbered files like "001 - security.html"
    let title = filename.replace(/\d+\s*-\s*/, '').replace('.html', '');
    title = title.split(' ').map(word => 
      word.charAt(0).toUpperCase() + word.slice(1).toLowerCase()
    ).join(' ');
    
    // Add appropriate emoji based on content
    if (title.toLowerCase().includes('security')) return '🔒 ' + title;
    if (title.toLowerCase().includes('faq')) return '❓ ' + title;
    if (title.toLowerCase().includes('guide')) return '📖 ' + title;
    if (title.toLowerCase().includes('tutorial')) return '📚 ' + title;
    if (title.toLowerCase().includes('configuration')) return '⚙️ ' + title;
    if (title.toLowerCase().includes('setup')) return '🔧 ' + title;
    
    return '📝 ' + title;
  }
  
  // Generate keywords for search
  function generateKeywords(title, filename) {
    const words = (title + ' ' + filename).toLowerCase()
      .replace(/[^a-z0-9\s]/g, ' ')
      .split(/\s+/)
      .filter(word => word.length > 2);
    
    return [...new Set(words)];
  }

  // Render the wiki list
  function renderWikiList() {
    if (!wikiList) return;
    
    wikiList.innerHTML = '';
    
    if (filteredPages.length === 0) {
      if (noResults) noResults.style.display = 'block';
      return;
    }
    
    if (noResults) noResults.style.display = 'none';
    
    // Group pages by folders
    const folders = groupPagesByFolders(filteredPages);
    renderFolderTree(folders, wikiList);
  }
  
  // Group pages by their actual folder structure
  function groupPagesByFolders(pages) {
    const folders = {};
    
    pages.forEach(page => {
      const folderName = page.folder;
      
      if (!folders[folderName]) {
        folders[folderName] = [];
      }
      folders[folderName].push(page);
    });
    
    return folders;
  }
  
  // Render expandable folder tree structure
  function renderFolderTree(folders, container) {
    // Sort folders by name (this will put them in order: 1 Guide, 2 Security, etc.)
    Object.keys(folders).sort().forEach(folderName => {
      const files = folders[folderName];
      
      // Skip if no files in folder
      if (files.length === 0) return;
      
      // Create folder container
      const folderLi = document.createElement('li');
      folderLi.className = 'wiki-folder-item';
      
      // Create folder header (clickable to expand/collapse)
      const folderHeader = document.createElement('div');
      folderHeader.className = 'wiki-folder-header';
      folderHeader.style.cssText = `
        display: flex;
        align-items: center;
        padding: 10px 16px;
        cursor: pointer;
        font-weight: 600;
        color: #7c5a2a;
        background: #f3e7d8;
        border-radius: 8px;
        margin-bottom: 6px;
        transition: all 0.2s ease;
        user-select: none;
        border: 1px solid #e9dcc7;
      `;
      
      // Create expand/collapse arrow
      const arrow = document.createElement('span');
      arrow.className = 'wiki-folder-arrow';
      arrow.textContent = '▶';
      arrow.style.cssText = `
        margin-right: 10px;
        font-size: 12px;
        transition: transform 0.3s ease;
        color: #7c5a2a;
        font-weight: bold;
      `;
      
      // Create folder icon and name
      const folderIcon = document.createElement('span');
      folderIcon.textContent = getFolderIcon(folderName);
      folderIcon.style.cssText = `
        margin-right: 10px;
        font-size: 18px;
      `;
      
      const folderNameSpan = document.createElement('span');
      folderNameSpan.textContent = folderName;
      folderNameSpan.style.fontSize = '15px';
      
      folderHeader.appendChild(arrow);
      folderHeader.appendChild(folderIcon);
      folderHeader.appendChild(folderNameSpan);
      
      // Create files container (initially hidden)
      const filesContainer = document.createElement('div');
      filesContainer.className = 'wiki-files-container';
      filesContainer.style.cssText = `
        display: none;
        margin-left: 24px;
        margin-bottom: 8px;
        border-left: 3px solid #e9dcc7;
        padding-left: 12px;
      `;
      
      // Create file list
      const filesList = document.createElement('ul');
      filesList.style.cssText = `
        list-style: none;
        padding: 0;
        margin: 0;
      `;
      
      // Add files to the list
      files.forEach((file, index) => {
        const fileLi = document.createElement('li');
        fileLi.style.marginBottom = '3px';
        
        const fileLink = document.createElement('a');
        fileLink.href = '#';
        fileLink.dataset.filename = file.file;
        fileLink.style.cssText = `
          display: flex;
          align-items: center;
          text-decoration: none;
          color: #6b4423;
          font-size: 14px;
          padding: 8px 12px;
          border-radius: 6px;
          transition: all 0.2s ease;
          border: 1px solid transparent;
        `;
        
        // Add file icon
        const fileIcon = document.createElement('span');
        fileIcon.textContent = '📝';
        fileIcon.style.cssText = `
          margin-right: 8px;
          font-size: 14px;
        `;
        
        fileLink.appendChild(fileIcon);
        fileLink.appendChild(document.createTextNode(file.title));
        
        // Add click handler
        fileLink.addEventListener('click', function(e) {
          e.preventDefault();
          
          // Remove active class from all links
          document.querySelectorAll('.wiki-files-container a').forEach(a => {
            a.style.background = 'transparent';
            a.style.color = '#6b4423';
            a.style.borderColor = 'transparent';
          });
          
          // Add active state to clicked link
          this.style.background = '#e9dcc7';
          this.style.color = '#4e3b23';
          this.style.borderColor = '#d2bfa3';
          
          loadWikiPage(this);
        });
        
        // Add hover effect
        fileLink.addEventListener('mouseenter', function() {
          if (this.style.background !== 'rgb(233, 220, 199)') {
            this.style.background = '#f8f5f1';
            this.style.borderColor = '#e9dcc7';
          }
        });
        
        fileLink.addEventListener('mouseleave', function() {
          if (this.style.background !== 'rgb(233, 220, 199)') {
            this.style.background = 'transparent';
            this.style.borderColor = 'transparent';
          }
        });
        
        fileLi.appendChild(fileLink);
        filesList.appendChild(fileLi);
      });
      
      filesContainer.appendChild(filesList);
      
      // Add expand/collapse functionality
      let isExpanded = false;
      folderHeader.addEventListener('click', function() {
        isExpanded = !isExpanded;
        
        if (isExpanded) {
          arrow.style.transform = 'rotate(90deg)';
          folderIcon.textContent = getFolderIcon(folderName, true);
          filesContainer.style.display = 'block';
          folderHeader.style.background = '#e9dcc7';
          folderHeader.style.borderColor = '#d2bfa3';
        } else {
          arrow.style.transform = 'rotate(0deg)';
          folderIcon.textContent = getFolderIcon(folderName, false);
          filesContainer.style.display = 'none';
          folderHeader.style.background = '#f3e7d8';
          folderHeader.style.borderColor = '#e9dcc7';
        }
      });
      
      // Add hover effect to folder header
      folderHeader.addEventListener('mouseenter', function() {
        if (!isExpanded) {
          this.style.background = '#e9dcc7';
          this.style.transform = 'translateY(-1px)';
          this.style.boxShadow = '0 2px 8px rgba(139, 69, 19, 0.1)';
        }
      });
      
      folderHeader.addEventListener('mouseleave', function() {
        if (!isExpanded) {
          this.style.background = '#f3e7d8';
          this.style.transform = 'translateY(0)';
          this.style.boxShadow = 'none';
        }
      });
      
      // Assemble the folder
      folderLi.appendChild(folderHeader);
      folderLi.appendChild(filesContainer);
      container.appendChild(folderLi);
    });
  }
  
  // Get appropriate icon for folder
  function getFolderIcon(folderName, isOpen = false) {
    const baseIcon = isOpen ? '📂' : '📁';
    
    if (folderName.includes('Guide')) return isOpen ? '📚' : '📖';
    if (folderName.includes('Security')) return '🔒';
    if (folderName.includes('Configuration')) return '⚙️';
    if (folderName.includes('Tutorial')) return '🎯';
    
    return baseIcon;
  }
  

  // Load a specific wiki page
  async function loadWikiPage(linkElement) {
    if (!wikiContent) return;
    
    // Remove active class from all links
    document.querySelectorAll('.wiki-list a').forEach(a => a.classList.remove('active'));
    linkElement.classList.add('active');
    
    const filename = linkElement.dataset.filename;
    
    try {
      // Show loading state with animation
      wikiContent.innerHTML = '<div style="text-align: center; color: #b8a07a; font-size: 1.1rem; margin-top: 80px; padding: 40px;">Loading...</div>';
      
      // Fetch the wiki page content
      const response = await fetch(`wiki/${filename}`);
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      
      const html = await response.text();
      
      // Extract content from the HTML (remove head, nav, footer)
      const parser = new DOMParser();
      const doc = parser.parseFromString(html, 'text/html');
      
      // Create a clean container
      const container = document.createElement('div');
      container.style.padding = '0';
      container.style.width = '100%';
      container.style.boxSizing = 'border-box';
      
      // Copy all styles from the original document
      const styles = doc.querySelectorAll('style');
      styles.forEach(style => {
        const newStyle = document.createElement('style');
        newStyle.textContent = style.textContent;
        container.appendChild(newStyle);
      });
      
      // Get the body content and clean it
      const bodyClone = doc.body.cloneNode(true);
      
      // Remove navigation, footer, and scripts
      const elementsToRemove = bodyClone.querySelectorAll('nav, footer, script');
      elementsToRemove.forEach(el => el.remove());
      
      // Add all remaining body content
      while (bodyClone.firstChild) {
        container.appendChild(bodyClone.firstChild);
      }
      
      // If we have content, display it
      if (container.children.length > 0) {
        wikiContent.innerHTML = '';
        wikiContent.appendChild(container);
        
        // Initialize mermaid if the page contains diagrams
        const mermaidElements = container.querySelectorAll('.mermaid');
        if (mermaidElements.length > 0) {
          if (typeof mermaid !== 'undefined') {
            mermaid.init(undefined, mermaidElements);
          } else {
            // Load mermaid if not available
            const script = document.createElement('script');
            script.src = 'https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js';
            script.onload = () => {
              mermaid.initialize({ startOnLoad: true, theme: 'default' });
              mermaid.init(undefined, mermaidElements);
            };
            document.head.appendChild(script);
          }
        }
      } else {
        wikiContent.innerHTML = '<div style="text-align: center; color: #b8a07a; font-size: 1.1rem; margin-top: 80px; padding: 40px;">Content not found in this page</div>';
      }
      
      // Scroll to top of content
      wikiContent.scrollTop = 0;
      
    } catch (error) {
      console.error('Error loading wiki page:', error);
      wikiContent.innerHTML = '<div style="text-align: center; color: #d2691e; font-size: 1.1rem; margin-top: 80px; padding: 40px;">⚠️ Error loading page content</div>';
    }
  }

  // Search functionality
  function performSearch(query) {
    const searchTerm = query.toLowerCase().trim();
    
    if (searchTerm === '') {
      filteredPages = [...allWikiPages];
    } else {
      filteredPages = allWikiPages.filter(page => {
        return page.title.toLowerCase().includes(searchTerm) ||
               page.keywords.some(keyword => keyword.toLowerCase().includes(searchTerm));
      });
    }
    
    renderWikiList();
    
    // Auto-load first result if search has results
    if (filteredPages.length > 0) {
      const firstLink = wikiList.querySelector('a');
      if (firstLink) {
        loadWikiPage(firstLink);
      }
    }
  }

  // Show error message
  function showError(message) {
    if (wikiContent) {
      wikiContent.innerHTML = `<div class="wiki-placeholder">⚠️ ${message}</div>`;
    }
  }

  // Set up search event listeners
  if (searchInput) {
    let searchTimeout;
    
    searchInput.addEventListener('input', function() {
      // Debounce search
      clearTimeout(searchTimeout);
      searchTimeout = setTimeout(() => {
        performSearch(this.value);
      }, 300);
    });
    
    searchInput.addEventListener('keydown', function(e) {
      if (e.key === 'Enter') {
        e.preventDefault();
        performSearch(this.value);
      }
    });
  }

  // Initialize wiki
  loadWikiPages().then(() => {
    // Load first page if available
    setTimeout(() => {
      const firstLink = wikiList && wikiList.querySelector('a');
      if (firstLink && (!searchInput || !searchInput.value)) {
        loadWikiPage(firstLink);
      }
    }, 300);
  });
}); 