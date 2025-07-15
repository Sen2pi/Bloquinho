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

  // === ANIMAÇÃO LETRAS CAINDO ===
  function randomBetween(a, b) {
    return Math.random() * (b - a) + a;
  }

  function animateFloatingLetters() {
    const letters = document.querySelectorAll('.floating-letter');
    letters.forEach(letter => {
      // Reset posição
      letter.style.transition = 'none';
      letter.style.opacity = 0;
      letter.style.transform = 'translateY(0px) rotate(0deg)';
      // Parâmetros aleatórios
      const delay = randomBetween(0, 4); // até 4s
      const duration = randomBetween(4, 8); // 4-8s
      const rotate = randomBetween(-90, 360);
      const finalOpacity = randomBetween(0.3, 0.8);
      setTimeout(() => {
        letter.style.transition = `transform ${duration}s linear, opacity ${duration/2}s ease-in-out`;
        letter.style.opacity = finalOpacity;
        letter.style.transform = `translateY(${window.innerHeight * 0.85}px) rotate(${rotate}deg)`;
        setTimeout(() => {
          letter.style.opacity = 0;
          // Reiniciar animação
          setTimeout(() => animateFloatingLetters(), randomBetween(500, 2000));
        }, duration * 1000 * 0.8);
      }, delay * 1000);
    });
  }

  if (document.querySelector('.animated-letters')) {
    animateFloatingLetters();
  }

  // === ANIMAÇÃO TRAÇO ANIMADO PARA TODOS OS CARDS ===
  function createRoundedRectPath(w, h, r) {
    // Gera um path SVG de um retângulo arredondado
    return `M${r},0 H${w - r} Q${w},0 ${w},${r} V${h - r} Q${w},${h} ${w - r},${h} H${r} Q0,${h} 0,${h - r} V${r} Q0,0 ${r},0 Z`;
  }

  function animateBorderPath(path, duration = 3000) {
    const length = path.getTotalLength();
    path.style.strokeDasharray = length;
    path.style.strokeDashoffset = length;
    
    function animate() {
      let start = null;
      function step(ts) {
        if (!start) start = ts;
        let progress = (ts - start) / duration;
        if (progress > 1) progress = 1;
        const drawLen = length * (1 - progress);
        path.style.strokeDashoffset = drawLen;
        
        if (progress < 1) {
          requestAnimationFrame(step);
        } else {
          setTimeout(() => {
            // Apaga o traço
            path.style.transition = 'stroke-dashoffset 0.5s';
            path.style.strokeDashoffset = length;
            setTimeout(() => {
              path.style.transition = '';
              animate();
            }, 600);
          }, 400);
        }
      }
      requestAnimationFrame(step);
    }
    animate();
  }

  function setupAnimatedBorder(cardId, svgId, duration = 3000) {
    const card = document.getElementById(cardId);
    const svg = document.getElementById(svgId);
    if (!card || !svg) return;

    function resizeAndAnimate() {
      // Limpa SVG
      svg.innerHTML = '';
      // Mede dimensões reais do card
      const w = card.offsetWidth;
      const h = card.offsetHeight;
      const r = 22; // raio dos cantos
      svg.setAttribute('viewBox', `0 0 ${w} ${h}`);
      svg.setAttribute('width', w);
      svg.setAttribute('height', h);
      // Cria path
      const path = document.createElementNS('http://www.w3.org/2000/svg', 'path');
      path.setAttribute('d', createRoundedRectPath(w, h, r));
      path.setAttribute('class', 'feature-border-path');
      path.setAttribute('id', svgId + '-path');
      svg.appendChild(path);
      // Anima traço
      animateBorderPath(path, duration);
    }
    resizeAndAnimate();
    window.addEventListener('resize', () => setTimeout(resizeAndAnimate, 300));
  }

  // Aplica animação para todos os cards
  for (let i = 1; i <= 11; i++) {
    const cardId = `feature-card-${i}`;
    const svgId = `feature-svg-${i}`;
    if (document.getElementById(cardId)) {
      setupAnimatedBorder(cardId, svgId, 3000);
    }
  }
}); 