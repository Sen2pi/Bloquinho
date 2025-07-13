document.addEventListener('DOMContentLoaded', () => {
  // Fade-in para cards e screenshots
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible');
      }
    });
  }, { threshold: 0.1 });

  document.querySelectorAll('.feature-card, .screenshot').forEach(el => {
    observer.observe(el);
  });

  // Scroll suave para âncoras
  document.querySelectorAll('nav ul li a').forEach(link => {
    link.addEventListener('click', e => {
      const href = link.getAttribute('href');
      if (href && href.startsWith('#')) {
        e.preventDefault();
        document.querySelector(href).scrollIntoView({ behavior: 'smooth' });
      }
    });
  });

  // Dark/Light mode toggle (auto based on system, can be expanded)
  function setDarkMode(dark) {
    document.body.classList.toggle('dark', dark);
  }
  setDarkMode(window.matchMedia('(prefers-color-scheme: dark)').matches);
  window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', e => {
    setDarkMode(e.matches);
  });
}); 