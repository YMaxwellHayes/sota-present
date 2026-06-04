// slide-presentation.js — Slide navigation and scaling for presentations

class SlidePresentation {
  constructor(viewportSelector) {
    this.viewport = document.querySelector(viewportSelector);
    this.stage = this.viewport.querySelector('.deck-stage');
    this.slides = Array.from(this.stage.querySelectorAll('.slide'));
    this.currentIndex = 0;
    this.scale = 1;

    this.init();
  }

  init() {
    this.calculateScale();
    this.showSlide(0);
    this.bindEvents();

    window.addEventListener('resize', () => this.calculateScale());
  }

  calculateScale() {
    const viewportWidth = window.innerWidth;
    const viewportHeight = window.innerHeight;
    const stageWidth = 1920;
    const stageHeight = 1080;

    this.scale = Math.min(viewportWidth / stageWidth, viewportHeight / stageHeight);

    const scaledWidth = stageWidth * this.scale;
    const scaledHeight = stageHeight * this.scale;
    const offsetX = (viewportWidth - scaledWidth) / 2;
    const offsetY = (viewportHeight - scaledHeight) / 2;

    this.stage.style.transform = `translate(${offsetX}px, ${offsetY}px) scale(${this.scale})`;
  }

  showSlide(index) {
    if (index < 0 || index >= this.slides.length) return;

    this.slides.forEach((slide, i) => {
      if (i === index) {
        slide.classList.add('active');
      } else {
        slide.classList.remove('active');
      }
    });

    this.currentIndex = index;
  }

  next() {
    this.showSlide(this.currentIndex + 1);
  }

  prev() {
    this.showSlide(this.currentIndex - 1);
  }

  goTo(index) {
    this.showSlide(index);
  }

  bindEvents() {
    // Keyboard navigation
    document.addEventListener('keydown', (e) => {
      switch (e.key) {
        case 'ArrowRight':
        case 'ArrowDown':
        case ' ':
        case 'PageDown':
          e.preventDefault();
          this.next();
          break;
        case 'ArrowLeft':
        case 'ArrowUp':
        case 'PageUp':
          e.preventDefault();
          this.prev();
          break;
        case 'Home':
          e.preventDefault();
          this.goTo(0);
          break;
        case 'End':
          e.preventDefault();
          this.goTo(this.slides.length - 1);
          break;
      }

      // Number keys (0-9) for quick navigation
      if (e.key >= '0' && e.key <= '9') {
        const targetIndex = parseInt(e.key) - 1;
        if (targetIndex >= 0 && targetIndex < this.slides.length) {
          e.preventDefault();
          this.goTo(targetIndex);
        }
      }
    });

    // Touch/swipe navigation
    let touchStartX = 0;
    let touchStartY = 0;

    this.viewport.addEventListener('touchstart', (e) => {
      touchStartX = e.touches[0].clientX;
      touchStartY = e.touches[0].clientY;
    });

    this.viewport.addEventListener('touchend', (e) => {
      const touchEndX = e.changedTouches[0].clientX;
      const touchEndY = e.changedTouches[0].clientY;
      const deltaX = touchEndX - touchStartX;
      const deltaY = touchEndY - touchStartY;

      // Horizontal swipe
      if (Math.abs(deltaX) > Math.abs(deltaY) && Math.abs(deltaX) > 50) {
        if (deltaX > 0) {
          this.prev();
        } else {
          this.next();
        }
      }
    });

    // Mouse wheel navigation
    let wheelTimeout;
    this.viewport.addEventListener('wheel', (e) => {
      e.preventDefault();

      clearTimeout(wheelTimeout);
      wheelTimeout = setTimeout(() => {
        if (e.deltaY > 0) {
          this.next();
        } else {
          this.prev();
        }
      }, 50);
    }, { passive: false });

    // Click navigation (tap zones)
    this.viewport.addEventListener('click', (e) => {
      const rect = this.viewport.getBoundingClientRect();
      const x = e.clientX - rect.left;
      const width = rect.width;

      // Left third: previous
      if (x < width / 3) {
        this.prev();
      }
      // Right two-thirds: next
      else {
        this.next();
      }
    });

    // Reset key
    document.addEventListener('keydown', (e) => {
      if (e.key === 'r' || e.key === 'R') {
        this.goTo(0);
      }
    });
  }
}

// Auto-initialize when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
  const viewport = document.querySelector('.deck-viewport');
  if (viewport) {
    window.deck = new SlidePresentation('.deck-viewport');
  }
});
