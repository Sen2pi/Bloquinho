// Wiki functionality for Bloquinho
// ATENÇÃO: Para navegação recursiva, gere um arquivo wiki_index.json na raiz da wiki com a estrutura de pastas/arquivos.
// Exemplo de estrutura:
// [
//   { "name": "1 Guide", "type": "folder", "children": [
//       { "name": "faq.html", "type": "file", "path": "1 Guide/faq.html" },
//       { "name": "1 Onboarding", "type": "folder", "children": [
//           { "name": "onboarding_tutorial.html", "type": "file", "path": "1 Guide/1 Onboarding/onboarding_tutorial.html" }
//       ]}
//   ]}, ...
// ]

// O arquivo wiki_index.json pode ser gerado por script Node, Python, etc.

// ---

document.addEventListener('DOMContentLoaded', function() {
  let allWikiPages = [];
  let filteredPages = [];
  let wikiTree = [];

  const searchInput = document.getElementById('wiki-search');
  const wikiList = document.getElementById('wiki-list');
  const noResults = document.getElementById('no-results');
  const wikiContent = document.getElementById('wiki-content');

  // Carrega a árvore de páginas a partir do JSON
  async function loadWikiTree() {
    try {
      const response = await fetch('wiki/wiki_index.json');
      if (!response.ok) throw new Error('wiki_index.json não encontrado');
      wikiTree = await response.json();
      allWikiPages = collectAllPages(wikiTree);
      filteredPages = [...allWikiPages];
      renderWikiList();
      if (allWikiPages.length === 0) showError('No wiki pages found.');
    } catch (e) {
      showError('Falha ao carregar wiki_index.json. Gere o arquivo para navegação recursiva.');
      console.error(e);
    }
  }

  // Coleta todas as páginas (arquivos) da árvore para busca
  function collectAllPages(tree, parentFolders = []) {
    let pages = [];
    for (const node of tree) {
      if (node.type === 'file') {
        const pageTitle = node.title || node.name; // Usa o título do JSON ou o nome do ficheiro como fallback
        pages.push({
          file: node.path,
          fileName: node.name,
          folder: parentFolders.join('/'),
          title: pageTitle,
          keywords: generateKeywords(pageTitle, node.path)
        });
      } else if (node.type === 'folder' && node.children) {
        pages = pages.concat(collectAllPages(node.children, [...parentFolders, node.name]));
      }
    }
    return pages;
  }

  // Renderiza a árvore recursivamente
  function renderWikiList() {
    if (!wikiList) return;
    wikiList.innerHTML = '';
    if (filteredPages.length === 0) {
      if (noResults) noResults.style.display = 'block';
      return;
    }
    if (noResults) noResults.style.display = 'none';
    // Filtra a árvore para mostrar só ramos relevantes na busca
    const filteredTree = filterTreeByPages(wikiTree, filteredPages);
    renderFolderRecursive(filteredTree, wikiList);
  }

  // Filtra a árvore para busca (só mantém ramos com arquivos encontrados)
  function filterTreeByPages(tree, pages) {
    function hasMatchingFile(node) {
      if (node.type === 'file') {
        return pages.some(p => p.file === node.path);
      } else if (node.type === 'folder' && node.children) {
        return node.children.some(hasMatchingFile);
      }
      return false;
    }
    return tree.filter(node => hasMatchingFile(node)).map(node => {
      if (node.type === 'folder') {
        return { ...node, children: filterTreeByPages(node.children, pages) };
      }
      return node;
    });
  }

  // Renderização recursiva da árvore
  function renderFolderRecursive(tree, container) {
    tree.forEach(node => {
      if (node.type === 'folder') {
        const folderLi = document.createElement('li');
        folderLi.className = 'wiki-folder-item';
        const folderHeader = document.createElement('div');
        folderHeader.className = 'wiki-folder-header';
        folderHeader.style.cssText = `display: flex; align-items: center; padding: 10px 16px; cursor: pointer; font-weight: 600; color: #7c5a2a; background: #f3e7d8; border-radius: 8px; margin-bottom: 6px; transition: all 0.2s ease; user-select: none; border: 1px solid #e9dcc7;`;
        const arrow = document.createElement('span');
        arrow.className = 'wiki-folder-arrow';
        arrow.textContent = '▶';
        arrow.style.cssText = `margin-right: 10px; font-size: 12px; transition: transform 0.3s ease; color: #7c5a2a; font-weight: bold;`;
        const folderIcon = document.createElement('span');
        folderIcon.textContent = getFolderIcon(node.name);
        folderIcon.style.cssText = `margin-right: 10px; font-size: 18px;`;
        const folderNameSpan = document.createElement('span');
        folderNameSpan.textContent = node.name;
        folderNameSpan.style.fontSize = '15px';
        folderHeader.appendChild(arrow);
        folderHeader.appendChild(folderIcon);
        folderHeader.appendChild(folderNameSpan);
        const filesContainer = document.createElement('div');
        filesContainer.className = 'wiki-files-container';
        filesContainer.style.cssText = `display: none; margin-left: 24px; margin-bottom: 8px; border-left: 3px solid #e9dcc7; padding-left: 12px;`;
        // Recursivo para filhos
        const filesList = document.createElement('ul');
        filesList.style.cssText = `list-style: none; padding: 0; margin: 0;`;
        renderFolderRecursive(node.children, filesList);
        filesContainer.appendChild(filesList);
        let isExpanded = false;
        folderHeader.addEventListener('click', function() {
          isExpanded = !isExpanded;
          if (isExpanded) {
            arrow.style.transform = 'rotate(90deg)';
            folderIcon.textContent = getFolderIcon(node.name, true);
            filesContainer.style.display = 'block';
            folderHeader.style.background = '#e9dcc7';
            folderHeader.style.borderColor = '#d2bfa3';
          } else {
            arrow.style.transform = 'rotate(0deg)';
            folderIcon.textContent = getFolderIcon(node.name, false);
            filesContainer.style.display = 'none';
            folderHeader.style.background = '#f3e7d8';
            folderHeader.style.borderColor = '#e9dcc7';
          }
        });
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
        folderLi.appendChild(folderHeader);
        folderLi.appendChild(filesContainer);
        container.appendChild(folderLi);
      } else if (node.type === 'file') {
        const fileLi = document.createElement('li');
        fileLi.style.marginBottom = '3px';
        const fileLink = document.createElement('a');
        fileLink.href = '#';
        fileLink.dataset.filename = node.path;
        fileLink.style.cssText = `display: flex; align-items: center; text-decoration: none; color: #6b4423; font-size: 14px; padding: 8px 12px; border-radius: 6px; transition: all 0.2s ease; border: 1px solid transparent;`;
        const fileIcon = document.createElement('span');
        fileIcon.textContent = '📝';
        fileIcon.style.cssText = `margin-right: 8px; font-size: 14px;`;
        fileLink.appendChild(fileIcon);
        fileLink.appendChild(document.createTextNode(node.title || node.name));
        fileLink.addEventListener('click', function(e) {
          e.preventDefault();
          document.querySelectorAll('.wiki-files-container a').forEach(a => {
            a.style.background = 'transparent';
            a.style.color = '#6b4423';
            a.style.borderColor = 'transparent';
          });
          this.style.background = '#e9dcc7';
          this.style.color = '#4e3b23';
          this.style.borderColor = '#d2bfa3';
          loadWikiPage(this);
        });
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
        container.appendChild(fileLi);
      }
    });
  }

  function getFolderIcon(folderName, isOpen = false) {
    const baseIcon = isOpen ? '📂' : '📁';
    if (folderName.includes('Guide')) return isOpen ? '📚' : '📖';
    if (folderName.includes('Security')) return '🔒';
    if (folderName.includes('Configuration')) return '⚙️';
    if (folderName.includes('Tutorial')) return '🎯';
    return baseIcon;
  }

  async function loadWikiPage(linkElement) {
    if (!wikiContent) return;
    document.querySelectorAll('.wiki-list a').forEach(a => a.classList.remove('active'));
    linkElement.classList.add('active');
    const filename = linkElement.dataset.filename;
    try {
      wikiContent.innerHTML = '<div style="text-align: center; color: #b8a07a; font-size: 1.1rem; margin-top: 80px; padding: 40px;">Loading...</div>';
      const response = await fetch(`wiki/${filename}`);
      if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);
      const html = await response.text();
      const parser = new DOMParser();
      const doc = parser.parseFromString(html, 'text/html');
      const container = document.createElement('div');
      container.style.padding = '0';
      container.style.width = '100%';
      container.style.boxSizing = 'border-box';
      const styles = doc.querySelectorAll('style');
      styles.forEach(style => {
        const newStyle = document.createElement('style');
        newStyle.textContent = style.textContent;
        container.appendChild(newStyle);
      });
      const bodyClone = doc.body.cloneNode(true);
      const elementsToRemove = bodyClone.querySelectorAll('nav, footer, script');
      elementsToRemove.forEach(el => el.remove());
      while (bodyClone.firstChild) {
        container.appendChild(bodyClone.firstChild);
      }
      if (container.children.length > 0) {
        wikiContent.innerHTML = '';
        wikiContent.appendChild(container);
        const mermaidElements = container.querySelectorAll('.mermaid');
        if (mermaidElements.length > 0) {
          if (typeof mermaid !== 'undefined') {
            mermaid.init(undefined, mermaidElements);
          } else {
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
      wikiContent.scrollTop = 0;
    } catch (error) {
      console.error('Error loading wiki page:', error);
      wikiContent.innerHTML = '<div style="text-align: center; color: #d2691e; font-size: 1.1rem; margin-top: 80px; padding: 40px;">⚠️ Error loading page content</div>';
    }
  }

  

  function generateKeywords(title, filename) {
    const words = (title + ' ' + filename).toLowerCase().replace(/[^a-z0-9\s]/g, ' ').split(/\s+/).filter(word => word.length > 2);
    return [...new Set(words)];
  }

  function generateKeywords(title, filename) {
    const words = (title + ' ' + filename).toLowerCase().replace(/[^a-z0-9\s]/g, ' ').split(/\s+/).filter(word => word.length > 2);
    return [...new Set(words)];
  }

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
    if (filteredPages.length > 0) {
      const firstLink = wikiList.querySelector('a');
      if (firstLink) {
        loadWikiPage(firstLink);
      }
    }
  }

  function showError(message) {
    if (wikiContent) {
      wikiContent.innerHTML = `<div class="wiki-placeholder">⚠️ ${message}</div>`;
    }
  }

  if (searchInput) {
    let searchTimeout;
    searchInput.addEventListener('input', function() {
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

  // Inicializa a wiki
  loadWikiTree().then(() => {
    setTimeout(() => {
      const firstLink = wikiList && wikiList.querySelector('a');
      if (firstLink && (!searchInput || !searchInput.value)) {
        loadWikiPage(firstLink);
      }
    }, 300);
  });
}); 