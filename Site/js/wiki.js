// Wiki functionality for Bloquinho
document.addEventListener('DOMContentLoaded', function() {
  let allWikiPages = [];
  let filteredPages = [];
  
  // Search functionality
  const searchInput = document.getElementById('wiki-search');
  const wikiList = document.getElementById('wiki-list');
  const noResults = document.getElementById('no-results');
  const wikiContent = document.getElementById('wiki-content');

  // Auto-detect and load wiki pages with hierarchical structure
  async function loadWikiPages() {
    try {
      // Generate potential file patterns (1.html, 1.1.html, 1.1.1.html, etc.)
      const potentialFiles = [];
      
      // Generate patterns up to 3 levels deep
      for (let i = 1; i <= 10; i++) {
        potentialFiles.push(`${i}.html`);
        for (let j = 1; j <= 10; j++) {
          potentialFiles.push(`${i}.${j}.html`);
          for (let k = 1; k <= 10; k++) {
            potentialFiles.push(`${i}.${j}.${k}.html`);
          }
        }
      }
      
      // Also check for files with titles like "001 - security.html"
      const namedFiles = [
        '001 - security.html',
        '002 - installation.html', 
        '003 - configuration.html',
        '004 - features.html',
        '005 - troubleshooting.html'
      ];
      
      allWikiPages = [];
      
      // Check each potential file
      for (const file of [...potentialFiles, ...namedFiles]) {
        try {
          const response = await fetch(`wiki/${file}`, { method: 'HEAD' });
          if (response.ok) {
            const pageData = createPageData(file);
            allWikiPages.push(pageData);
          }
        } catch (error) {
          // File doesn't exist, skip it
          continue;
        }
      }
      
      // Sort pages by hierarchy
      allWikiPages.sort((a, b) => {
        // First sort by hierarchy level, then by number
        if (a.level !== b.level) {
          return a.level - b.level;
        }
        return a.sortKey.localeCompare(b.sortKey, undefined, { numeric: true });
      });
      
      filteredPages = [...allWikiPages];
      renderWikiList();
      
      // If no pages found, show a helpful message
      if (allWikiPages.length === 0) {
        showError('No wiki pages found. Add HTML files to the wiki/ directory.');
      }
    } catch (error) {
      console.error('Error loading wiki pages:', error);
      showError('Failed to load wiki pages');
    }
  }
  
  // Create page data with hierarchy information
  function createPageData(filename) {
    const title = extractTitleFromFilename(filename);
    const keywords = generateKeywords(title, filename);
    const hierarchy = parseHierarchy(filename);
    
    return {
      file: filename,
      title: title,
      keywords: keywords,
      level: hierarchy.level,
      numbers: hierarchy.numbers,
      sortKey: hierarchy.sortKey,
      isFolder: hierarchy.level < 3 // Consider it a folder if it's not at the deepest level
    };
  }
  
  // Parse hierarchy from filename
  function parseHierarchy(filename) {
    // Extract number pattern (1, 1.1, 1.1.1, etc.)
    const numberMatch = filename.match(/^(\d+(?:\.\d+)*)/); 
    
    if (numberMatch) {
      const numberPart = numberMatch[1];
      const numbers = numberPart.split('.').map(n => parseInt(n));
      return {
        level: numbers.length,
        numbers: numbers,
        sortKey: numberPart
      };
    }
    
    // For named files like "001 - security.html", use a simple numbering
    const namedMatch = filename.match(/^(\d+)/); 
    if (namedMatch) {
      const num = parseInt(namedMatch[1]);
      return {
        level: 1,
        numbers: [num],
        sortKey: String(num).padStart(3, '0')
      };
    }
    
    return {
      level: 1,
      numbers: [999],
      sortKey: '999'
    };
  }
  
  // Extract title from filename
  function extractTitleFromFilename(filename) {
    // Handle numbered files (1.html, 1.1.html, etc.)
    const numberMatch = filename.match(/^(\d+(?:\.\d+)*)\.html$/);
    if (numberMatch) {
      const numbers = numberMatch[1];
      const level = numbers.split('.').length;
      
      // Generate titles based on hierarchy level
      if (level === 1) {
        const sectionTitles = {
          '1': '🔒 Security',
          '2': '📦 Installation', 
          '3': '⚙️ Configuration',
          '4': '✨ Features',
          '5': '🔧 Troubleshooting'
        };
        return sectionTitles[numbers] || `📝 Section ${numbers}`;
      } else if (level === 2) {
        return `📎 Subsection ${numbers}`;
      } else {
        return `📄 Page ${numbers}`;
      }
    }
    
    // Handle named files like "001 - security.html"
    let title = filename.replace(/\d+\s*-\s*/, '').replace('.html', '');
    // Capitalize first letter of each word
    title = title.split(' ').map(word => 
      word.charAt(0).toUpperCase() + word.slice(1).toLowerCase()
    ).join(' ');
    
    // Add appropriate emoji based on content
    if (title.toLowerCase().includes('security')) return '🔒 ' + title;
    if (title.toLowerCase().includes('installation')) return '📦 ' + title;
    if (title.toLowerCase().includes('configuration')) return '⚙️ ' + title;
    if (title.toLowerCase().includes('features')) return '✨ ' + title;
    if (title.toLowerCase().includes('troubleshooting')) return '🔧 ' + title;
    
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
    renderSelectDropdowns(folders, wikiList);
  }
  
  // Group pages by their folder structure
  function groupPagesByFolders(pages) {
    const folders = {};
    
    pages.forEach(page => {
      let folderName;
      
      if (page.numbers.length === 1) {
        // Top level file (1.html) - create its own folder
        folderName = `${page.numbers[0]} - ${page.title}`;
        if (!folders[folderName]) {
          folders[folderName] = [];
        }
        folders[folderName].push(page);
      } else if (page.numbers.length === 2) {
        // Second level (1.1.html) - group under main section
        folderName = `${page.numbers[0]} - Section ${page.numbers[0]}`;
        if (!folders[folderName]) {
          folders[folderName] = [];
        }
        folders[folderName].push(page);
      } else if (page.numbers.length >= 3) {
        // Third level+ (1.1.1.html) - group under subsection
        folderName = `${page.numbers[0]}.${page.numbers[1]} - Subsection ${page.numbers[0]}.${page.numbers[1]}`;
        if (!folders[folderName]) {
          folders[folderName] = [];
        }
        folders[folderName].push(page);
      } else {
        // Named files (001 - security.html) - use their own category
        folderName = 'Documentation';
        if (!folders[folderName]) {
          folders[folderName] = [];
        }
        folders[folderName].push(page);
      }
    });
    
    return folders;
  }
  
  // Render select dropdowns for each folder
  function renderSelectDropdowns(folders, container) {
    Object.keys(folders).sort().forEach(folderName => {
      const files = folders[folderName];
      
      // Create folder label
      const folderLabel = document.createElement('div');
      folderLabel.className = 'wiki-folder-label';
      folderLabel.textContent = folderName;
      folderLabel.style.cssText = `
        font-weight: bold;
        color: #7c5a2a;
        margin: 16px 0 8px 0;
        padding: 0 16px;
        font-size: 0.9rem;
        text-transform: uppercase;
        letter-spacing: 0.5px;
      `;
      
      // Create select dropdown
      const select = document.createElement('select');
      select.className = 'wiki-folder-select';
      select.style.cssText = `
        width: calc(100% - 32px);
        margin: 0 16px 12px 16px;
        padding: 8px 12px;
        border: 2px solid #e9dcc7;
        border-radius: 6px;
        background: #fff8ef;
        color: #4e3b23;
        font-size: 14px;
        cursor: pointer;
        outline: none;
      `;
      
      // Add default option
      const defaultOption = document.createElement('option');
      defaultOption.value = '';
      defaultOption.textContent = `Select from ${folderName}...`;
      defaultOption.disabled = true;
      defaultOption.selected = true;
      select.appendChild(defaultOption);
      
      // Add file options
      files.forEach(file => {
        const option = document.createElement('option');
        option.value = file.file;
        option.textContent = file.title;
        select.appendChild(option);
      });
      
      // Handle selection
      select.addEventListener('change', function() {
        if (this.value) {
          // Reset other selects
          document.querySelectorAll('.wiki-folder-select').forEach(s => {
            if (s !== this) {
              s.selectedIndex = 0;
            }
          });
          
          // Load the selected page
          const fakeLink = {
            dataset: { filename: this.value },
            classList: { add: () => {}, remove: () => {} }
          };
          loadWikiPage(fakeLink);
        }
      });
      
      // Add hover effect
      select.addEventListener('mouseenter', function() {
        this.style.borderColor = '#7c5a2a';
      });
      
      select.addEventListener('mouseleave', function() {
        this.style.borderColor = '#e9dcc7';
      });
      
      // Create container for this folder
      const folderContainer = document.createElement('li');
      folderContainer.appendChild(folderLabel);
      folderContainer.appendChild(select);
      
      container.appendChild(folderContainer);
    });
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