// NotionClone On-Premises Dashboard JavaScript

// Application data
const appData = {
  project: {
    name: "NotionClone On-Premises",
    description: "Aplicação similar ao Notion que funciona completamente on-premises, sem limitações de planos e com backup cloud integrado",
    objectives: [
      "Funcionalidade Completa - Implementar todas as funcionalidades do Notion sem limitações",
      "On-Premises - Execução local sem dependência de serviços cloud externos", 
      "Backup Cloud - Integração com OneDrive, Google Drive e clouds privadas",
      "Sem Planos - Acesso completo a todas as funcionalidades sem restrições",
      "Open Source - Licença que permite uso comercial e modificações"
    ]
  },
  techStack: [
    {"layer": "Frontend", "primary": "React + TypeScript", "alternative": "SvelteKit ou Vue.js", "justification": "Ecossistema maduro, grande comunidade"},
    {"layer": "Backend Framework", "primary": "Next.js 13+ (App Router)", "alternative": "Express.js + Nest.js", "justification": "SSR, performance, API routes integradas"},
    {"layer": "Runtime", "primary": "Node.js", "alternative": "Deno", "justification": "Ecossistema JavaScript consolidado"},
    {"layer": "Linguagem", "primary": "TypeScript", "alternative": "JavaScript", "justification": "Type safety, melhor DX"},
    {"layer": "Base de Dados", "primary": "PostgreSQL + Redis", "alternative": "MongoDB + MemcacheD", "justification": "ACID compliance + caching"},
    {"layer": "Editor", "primary": "Editor.js ou ProseMirror", "alternative": "TipTap ou CKEditor 5", "justification": "Flexibilidade de blocos estruturados"},
    {"layer": "Colaboração Real-time", "primary": "WebSockets + Yjs CRDTs", "alternative": "Liveblocks ou Supabase", "justification": "Baixa latência, conflict resolution"},
    {"layer": "Autenticação", "primary": "OAuth 2.0 + JWT", "alternative": "Auth0 ou Keycloak", "justification": "Standards da indústria"},
    {"layer": "Cloud Storage APIs", "primary": "OneDrive API + Google Drive", "alternative": "APIs de nuvem privada", "justification": "Integração nativa com principais clouds"},
    {"layer": "Containerização", "primary": "Docker + Docker Compose", "alternative": "Podman", "justification": "Orquestração simples, portabilidade"},
    {"layer": "Proxy/Load Balancer", "primary": "Nginx", "alternative": "Traefik", "justification": "High performance, configuração simples"},
    {"layer": "Monitorização", "primary": "Prometheus + Grafana", "alternative": "ELK Stack", "justification": "Monitoring stack completo"}
  ],
  notionComparison: [
    {"feature": "Blocos ilimitados", "free": "Limitado para +2 membros", "plus": "Ilimitado", "business": "Ilimitado", "enterprise": "Ilimitado", "ourSolution": "Ilimitado"},
    {"feature": "Upload de arquivos", "free": "Até 5 MB", "plus": "Ilimitado", "business": "Ilimitado", "enterprise": "Ilimitado", "ourSolution": "Ilimitado"},
    {"feature": "Histórico da página", "free": "7 dias", "plus": "30 dias", "business": "90 dias", "enterprise": "Ilimitado", "ourSolution": "Ilimitado"},
    {"feature": "Vagas de convidados", "free": "10", "plus": "100", "business": "250", "enterprise": "250+", "ourSolution": "Ilimitado"},
    {"feature": "Espaços de equipe privados", "free": "Não", "plus": "Não", "business": "Sim", "enterprise": "Sim", "ourSolution": "Sim"},
    {"feature": "IA do Notion", "free": "Teste limitado", "plus": "Teste limitado", "business": "Incluída", "enterprise": "Incluída", "ourSolution": "Opcional"},
    {"feature": "Formulários", "free": "Básico", "plus": "Personalizado", "business": "Avançado", "enterprise": "Avançado", "ourSolution": "Avançado"},
    {"feature": "Gráficos", "free": "1", "plus": "Ilimitado", "business": "Ilimitado", "enterprise": "Ilimitado", "ourSolution": "Ilimitado"},
    {"feature": "Automações", "free": "Básico", "plus": "Personalizado", "business": "Avançado", "enterprise": "Avançado", "ourSolution": "Avançado"},
    {"feature": "API pública", "free": "Sim", "plus": "Sim", "business": "Sim", "enterprise": "Sim", "ourSolution": "Sim"},
    {"feature": "Webhooks", "free": "Não", "plus": "Sim", "business": "Sim", "enterprise": "Sim", "ourSolution": "Sim"},
    {"feature": "SSO SAML", "free": "Não", "plus": "Não", "business": "Sim", "enterprise": "Sim", "ourSolution": "Sim"},
    {"feature": "Auditoria", "free": "Não", "plus": "Não", "business": "Não", "enterprise": "Sim", "ourSolution": "Sim"}
  ],
  developmentPhases: [
    {"phase": "Fase 1: MVP", "duration": "8-12 semanas", "description": "Setup inicial, autenticação básica, editor fundamental, PostgreSQL, interface básica", "deliverables": ["Sistema de autenticação", "Editor de blocos básico", "Base de dados", "Interface inicial"]},
    {"phase": "Fase 2: Funcionalidades Core", "duration": "8-10 semanas", "description": "Bases de dados, sistema de páginas, partilha básica, backup cloud", "deliverables": ["Bases de dados personalizadas", "Navegação de páginas", "Partilha", "Backup cloud"]},
    {"phase": "Fase 3: Colaboração", "duration": "6-8 semanas", "description": "Edição colaborativa, comentários, permissões, histórico", "deliverables": ["Edição real-time", "Sistema de comentários", "Permissões", "Versionamento"]},
    {"phase": "Fase 4: Funcionalidades Avançadas", "duration": "6-8 semanas", "description": "Automações, API pública, templates, monitorização", "deliverables": ["Automações", "API REST", "Templates", "Monitoring"]},
    {"phase": "Fase 5: Polimento e Deploy", "duration": "4-6 semanas", "description": "Testes, otimização, documentação, deployment", "deliverables": ["Testes completos", "Performance", "Documentação", "Deploy production"]}
  ],
  coreFeatures: [
    {"category": "Editor e Blocos", "features": ["Sistema de blocos", "Texto, listas, imagens, tabelas", "Drag & drop", "Comandos slash", "Markdown shortcuts"]},
    {"category": "Base de Dados", "features": ["Bases de dados personalizadas", "Propriedades e filtros", "Vistas múltiplas", "Fórmulas", "Templates"]},
    {"category": "Colaboração", "features": ["Edição real-time", "Comentários", "Partilha", "Permissões", "Histórico"]},
    {"category": "Organização", "features": ["Hierarquia de páginas", "Workspaces", "Favoritos", "Pesquisa global", "Tags"]},
    {"category": "Automação", "features": ["Botões template", "Automações", "Webhooks", "API pública"]},
    {"category": "Backup", "features": ["OneDrive", "Google Drive", "Clouds privadas", "Restore", "Sincronização"]}
  ],
  costAnalysis: {
    notion: {
      business50Users: 975,
      businessPerYear: 11700,
      enterprise50Users: 1275,
      enterprisePerYear: 15300
    },
    ourSolution: {
      development: "20000-30000",
      serverMonthly: "50-100",
      yearlyOperational: 720,
      savingsVsNotion: 94
    }
  }
};

// DOM Elements
let currentSection = 'overview';
let completedFeatures = new Set();

// Initialize the application
document.addEventListener('DOMContentLoaded', function() {
  initializeNavigation();
  initializeThemeToggle();
  renderTechStack();
  renderComparison();
  renderFeatures();
  renderDevelopmentTimeline();
  initializeROICalculator();
  
  // Show initial section
  showSection('overview');
});

// Navigation functionality
function initializeNavigation() {
  const navLinks = document.querySelectorAll('.nav-link');
  
  navLinks.forEach(link => {
    link.addEventListener('click', function(e) {
      e.preventDefault();
      const sectionId = this.getAttribute('data-section');
      showSection(sectionId);
      updateActiveNavLink(this);
    });
  });
}

function showSection(sectionId) {
  // Hide all sections
  document.querySelectorAll('.content-section').forEach(section => {
    section.classList.remove('active');
  });
  
  // Show target section
  const targetSection = document.getElementById(sectionId);
  if (targetSection) {
    targetSection.classList.add('active');
    currentSection = sectionId;
  }
}

function updateActiveNavLink(activeLink) {
  document.querySelectorAll('.nav-link').forEach(link => {
    link.classList.remove('active');
  });
  activeLink.classList.add('active');
}

function scrollToSection(sectionId) {
  showSection(sectionId);
  const navLink = document.querySelector(`[data-section="${sectionId}"]`);
  if (navLink) {
    updateActiveNavLink(navLink);
  }
}

// Theme toggle functionality
function initializeThemeToggle() {
  const themeToggle = document.getElementById('theme-toggle');
  const themeIcon = document.getElementById('theme-icon');
  
  // Check for saved theme preference
  const savedTheme = localStorage.getItem('theme') || 'light';
  document.documentElement.setAttribute('data-color-scheme', savedTheme);
  updateThemeButton(savedTheme);
  
  themeToggle.addEventListener('click', function() {
    const currentTheme = document.documentElement.getAttribute('data-color-scheme');
    const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
    
    document.documentElement.setAttribute('data-color-scheme', newTheme);
    localStorage.setItem('theme', newTheme);
    updateThemeButton(newTheme);
  });
  
  function updateThemeButton(theme) {
    const themeText = themeToggle.querySelector('span:last-child') || themeToggle;
    if (theme === 'dark') {
      themeIcon.textContent = '☀️';
      themeText.textContent = '☀️ Tema Claro';
    } else {
      themeIcon.textContent = '🌙';
      themeText.textContent = '🌙 Tema Escuro';
    }
  }
}

// Render tech stack table
function renderTechStack() {
  const container = document.getElementById('tech-stack-content');
  if (!container) return;
  
  container.innerHTML = appData.techStack.map(item => `
    <div class="stack-row">
      <div>${item.layer}</div>
      <div><strong>${item.primary}</strong></div>
      <div>${item.alternative}</div>
      <div>${item.justification}</div>
    </div>
  `).join('');
}

// Render comparison table
function renderComparison() {
  const container = document.getElementById('comparison-content');
  if (!container) return;
  
  container.innerHTML = appData.notionComparison.map(item => `
    <div class="comparison-row">
      <div>${item.feature}</div>
      <div>${item.free}</div>
      <div>${item.plus}</div>
      <div>${item.business}</div>
      <div>${item.enterprise}</div>
      <div>${item.ourSolution}</div>
    </div>
  `).join('');
}

// Render features checklist
function renderFeatures() {
  const container = document.getElementById('features-grid');
  if (!container) return;
  
  container.innerHTML = appData.coreFeatures.map(category => `
    <div class="feature-category">
      <h3>${category.category}</h3>
      <ul class="feature-list">
        ${category.features.map((feature, index) => {
          const featureId = `${category.category}-${index}`;
          return `
            <li class="feature-item" data-feature-id="${featureId}">
              <input type="checkbox" class="feature-checkbox" id="${featureId}" 
                     onchange="toggleFeature('${featureId}')">
              <label for="${featureId}">${feature}</label>
            </li>
          `;
        }).join('')}
      </ul>
    </div>
  `).join('');
}

// Toggle feature completion
function toggleFeature(featureId) {
  const checkbox = document.getElementById(featureId);
  const featureItem = checkbox.closest('.feature-item');
  
  if (checkbox.checked) {
    completedFeatures.add(featureId);
    featureItem.classList.add('completed');
  } else {
    completedFeatures.delete(featureId);
    featureItem.classList.remove('completed');
  }
  
  updateProgressStats();
}

function updateProgressStats() {
  const totalFeatures = document.querySelectorAll('.feature-checkbox').length;
  const completedCount = completedFeatures.size;
  const progressPercentage = Math.round((completedCount / totalFeatures) * 100);
  
  // You could add a progress indicator here if desired
  console.log(`Progress: ${completedCount}/${totalFeatures} (${progressPercentage}%)`);
}

// Render development timeline
function renderDevelopmentTimeline() {
  const container = document.getElementById('development-timeline');
  if (!container) return;
  
  container.innerHTML = `
    <div class="timeline-container">
      ${appData.developmentPhases.map((phase, index) => `
        <div class="timeline-item">
          <div class="timeline-marker">${index + 1}</div>
          <div class="timeline-content">
            <h3>${phase.phase}</h3>
            <div class="timeline-duration">${phase.duration}</div>
            <p>${phase.description}</p>
            <ul class="timeline-deliverables">
              ${phase.deliverables.map(deliverable => `
                <li>${deliverable}</li>
              `).join('')}
            </ul>
          </div>
        </div>
      `).join('')}
    </div>
  `;
}

// ROI Calculator functionality
function initializeROICalculator() {
  const usersInput = document.getElementById('users');
  const yearsInput = document.getElementById('years');
  
  if (!usersInput || !yearsInput) return;
  
  // Add event listeners
  usersInput.addEventListener('input', calculateROI);
  yearsInput.addEventListener('input', calculateROI);
  
  // Initial calculation
  calculateROI();
}

function calculateROI() {
  const users = parseInt(document.getElementById('users').value) || 50;
  const years = parseInt(document.getElementById('years').value) || 3;
  
  // Notion Business pricing: €19.50 per user/month
  const notionMonthlyPerUser = 19.50;
  const notionMonthlyTotal = users * notionMonthlyPerUser;
  const notionYearlyTotal = notionMonthlyTotal * 12;
  const notionTotalCost = notionYearlyTotal * years;
  
  // Our solution costs
  const developmentCost = 25000; // Average of 20k-30k
  const operationalYearlyCost = 720;
  const ourTotalCost = developmentCost + (operationalYearlyCost * years);
  
  // Calculate savings and ROI
  const totalSavings = notionTotalCost - ourTotalCost;
  const roi = Math.round((totalSavings / ourTotalCost) * 100);
  
  // Update UI
  document.getElementById('notion-cost').textContent = `€${notionTotalCost.toLocaleString()}`;
  document.getElementById('our-cost').textContent = `€${ourTotalCost.toLocaleString()}`;
  document.getElementById('savings').textContent = `€${totalSavings.toLocaleString()}`;
  document.getElementById('roi').textContent = `${roi}%`;
  
  // Update colors based on savings
  const savingsElement = document.getElementById('savings');
  const roiElement = document.getElementById('roi');
  
  if (totalSavings > 0) {
    savingsElement.style.color = 'var(--color-success)';
    roiElement.style.color = 'var(--color-success)';
  } else {
    savingsElement.style.color = 'var(--color-error)';
    roiElement.style.color = 'var(--color-error)';
  }
}

// Utility functions for smooth scrolling and animations
function smoothScrollTo(element) {
  element.scrollIntoView({
    behavior: 'smooth',
    block: 'start'
  });
}

// Add some interactive enhancements
document.addEventListener('DOMContentLoaded', function() {
  // Add hover effects to cards
  const cards = document.querySelectorAll('.objective-card, .cost-card, .backup-card, .spec-card');
  cards.forEach(card => {
    card.addEventListener('mouseenter', function() {
      this.style.transform = 'translateY(-4px)';
    });
    
    card.addEventListener('mouseleave', function() {
      this.style.transform = 'translateY(0)';
    });
  });
  
  // Add click animation to buttons
  const buttons = document.querySelectorAll('.btn');
  buttons.forEach(button => {
    button.addEventListener('click', function() {
      this.style.transform = 'scale(0.95)';
      setTimeout(() => {
        this.style.transform = 'scale(1)';
      }, 150);
    });
  });
});

// Mobile navigation toggle (if needed)
function toggleMobileNav() {
  const sidebar = document.querySelector('.sidebar');
  sidebar.classList.toggle('mobile-open');
}

// Handle window resize for responsive behavior
window.addEventListener('resize', function() {
  if (window.innerWidth > 768) {
    const sidebar = document.querySelector('.sidebar');
    sidebar.classList.remove('mobile-open');
  }
});

// Keyboard navigation support
document.addEventListener('keydown', function(e) {
  if (e.ctrlKey || e.metaKey) {
    switch(e.key) {
      case '1':
        e.preventDefault();
        showSection('overview');
        updateActiveNavLink(document.querySelector('[data-section="overview"]'));
        break;
      case '2':
        e.preventDefault();
        showSection('architecture');
        updateActiveNavLink(document.querySelector('[data-section="architecture"]'));
        break;
      case '3':
        e.preventDefault();
        showSection('features');
        updateActiveNavLink(document.querySelector('[data-section="features"]'));
        break;
      case '4':
        e.preventDefault();
        showSection('development');
        updateActiveNavLink(document.querySelector('[data-section="development"]'));
        break;
      case '5':
        e.preventDefault();
        showSection('specifications');
        updateActiveNavLink(document.querySelector('[data-section="specifications"]'));
        break;
      case '6':
        e.preventDefault();
        showSection('backup');
        updateActiveNavLink(document.querySelector('[data-section="backup"]'));
        break;
      case '7':
        e.preventDefault();
        showSection('estimates');
        updateActiveNavLink(document.querySelector('[data-section="estimates"]'));
        break;
    }
  }
});

// Export functions for global access
window.scrollToSection = scrollToSection;
window.toggleFeature = toggleFeature;
window.toggleMobileNav = toggleMobileNav;