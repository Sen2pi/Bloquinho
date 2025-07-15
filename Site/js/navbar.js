// Mobile Navigation Functionality
document.addEventListener('DOMContentLoaded', function() {
  const navToggle = document.querySelector('.nav-toggle');
  const navLinks = document.querySelector('.nav-links');
  
  // Theme toggle functionality
  const themeToggle = document.querySelector('#theme-toggle');
  const body = document.body;
  
  // Load saved theme
  const savedTheme = localStorage.getItem('theme') || 'light';
  if (savedTheme === 'dark') {
    body.classList.add('dark-theme');
    body.classList.remove('light-theme');
    if (themeToggle) themeToggle.checked = true;
  } else {
    body.classList.add('light-theme');
    body.classList.remove('dark-theme');
    if (themeToggle) themeToggle.checked = false;
  }
  
  // Theme toggle event listener
  if (themeToggle) {
    themeToggle.addEventListener('change', function() {
      if (this.checked) {
        body.classList.add('dark-theme');
        body.classList.remove('light-theme');
        localStorage.setItem('theme', 'dark');
      } else {
        body.classList.add('light-theme');
        body.classList.remove('dark-theme');
        localStorage.setItem('theme', 'light');
      }
    });
  }
  
  if (navToggle && navLinks) {
    // Toggle menu function
    function toggleMenu() {
      navLinks.classList.toggle('open');
      navToggle.classList.toggle('active');
      
      // Prevent body scroll when menu is open
      if (navLinks.classList.contains('open')) {
        document.body.style.overflow = 'hidden';
      } else {
        document.body.style.overflow = '';
      }
    }
    
    // Add click event to toggle button
    navToggle.addEventListener('click', toggleMenu);
    
    // Close menu when clicking outside
    document.addEventListener('click', function(event) {
      const isClickInsideNav = navLinks.contains(event.target) || navToggle.contains(event.target);
      
      if (!isClickInsideNav && navLinks.classList.contains('open')) {
        navLinks.classList.remove('open');
        navToggle.classList.remove('active');
        document.body.style.overflow = '';
      }
    });
    
    // Close menu when clicking on a link
    navLinks.querySelectorAll('a').forEach(link => {
      link.addEventListener('click', function() {
        navLinks.classList.remove('open');
        navToggle.classList.remove('active');
        document.body.style.overflow = '';
      });
    });
    
    // Close menu on window resize (if screen becomes larger)
    window.addEventListener('resize', function() {
      if (window.innerWidth > 700 && navLinks.classList.contains('open')) {
        navLinks.classList.remove('open');
        navToggle.classList.remove('active');
        document.body.style.overflow = '';
      }
    });
    
    // Add keyboard support (ESC key)
    document.addEventListener('keydown', function(event) {
      if (event.key === 'Escape' && navLinks.classList.contains('open')) {
        navLinks.classList.remove('open');
        navToggle.classList.remove('active');
        document.body.style.overflow = '';
      }
    });
  }
});

// Global toggle function for inline onclick
function toggleMenu() {
  const navToggle = document.querySelector('.nav-toggle');
  const navLinks = document.querySelector('.nav-links');
  
  if (navToggle && navLinks) {
    navLinks.classList.toggle('open');
    navToggle.classList.toggle('active');
    
    // Prevent body scroll when menu is open
    if (navLinks.classList.contains('open')) {
      document.body.style.overflow = 'hidden';
    } else {
      document.body.style.overflow = '';
    }
  }
} 