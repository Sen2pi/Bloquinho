document.addEventListener('DOMContentLoaded', () => {
  const menu = document.getElementById('wiki-menu');
  const main = document.getElementById('wiki-main');
  if (!menu || !main) return;

  fetch('wiki/index.json')
    .then(res => res.json())
    .then(pages => {
      menu.innerHTML = '<ul>' + pages.map((page, i) =>
        `<li><a href="#" data-filename="${page.file}" ${i === 0 ? 'class="active"' : ''}>${page.title}</a></li>`
      ).join('') + '</ul>';
      // Load first page by default
      if (pages.length > 0) loadWikiPage(pages[0].file);
      menu.querySelectorAll('a').forEach(link => {
        link.addEventListener('click', e => {
          e.preventDefault();
          menu.querySelectorAll('a').forEach(a => a.classList.remove('active'));
          link.classList.add('active');
          loadWikiPage(link.getAttribute('data-filename'));
        });
      });
    });

  function loadWikiPage(file) {
    const content = document.getElementById('wiki-content');
    if (!content) return;
    // Animação de virar página
    content.classList.remove('page-flip');
    fetch('wiki/' + file)
      .then(res => res.text())
      .then(html => {
        content.innerHTML = html;
        setTimeout(() => content.classList.add('page-flip'), 10);
      });
  }
}); 