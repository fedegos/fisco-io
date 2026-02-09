(function() {
  'use strict';

  // Flash: auto-dismiss y click para cerrar
  function initFlashes() {
    document.querySelectorAll('[data-flash]').forEach(function(el) {
      var t = setTimeout(function() { el.style.display = 'none'; }, 5000);
      el.addEventListener('click', function() { clearTimeout(t); el.style.display = 'none'; });
    });
  }

  // Confirm en formularios con data-confirm
  function initConfirmForms() {
    document.querySelectorAll('form[data-confirm]').forEach(function(form) {
      form.addEventListener('submit', function(e) {
        if (!confirm(form.getAttribute('data-confirm'))) e.preventDefault();
      });
    });
  }

  // Dropdowns (details.actions-dropdown): fixed, dentro del viewport, sin flash de scroll en la tabla
  function initDropdowns() {
    var dropdowns = document.querySelectorAll('.actions-dropdown');
    var GAP = 4;
    var PAD = 8;

    function closeAll() {
      dropdowns.forEach(function(d) {
        d.removeAttribute('open');
        var menu = d.querySelector('.actions-dropdown__menu');
        if (menu) {
          menu.style.position = '';
          menu.style.top = '';
          menu.style.left = '';
          menu.style.visibility = '';
          menu.style.maxHeight = '';
          menu.style.overflowY = '';
        }
      });
    }

    function positionMenu(d) {
      var summary = d.querySelector('summary');
      var menu = d.querySelector('.actions-dropdown__menu');
      if (!summary || !menu) return;
      var rect = summary.getBoundingClientRect();
      /* La regla CSS .actions-dropdown[open] .actions-dropdown__menu ya pone fixed + hidden en el primer paint */
      requestAnimationFrame(function() {
        var menuH = menu.offsetHeight;
        var menuW = menu.offsetWidth;
        var vw = window.innerWidth;
        var vh = window.innerHeight;
        var openBelow = rect.bottom + GAP + menuH <= vh;
        var openAbove = !openBelow;
        var top = openBelow ? (rect.bottom + GAP) : (rect.top - GAP - menuH);
        var left = rect.left;
        if (left + menuW > vw - PAD) left = vw - menuW - PAD;
        if (left < PAD) left = PAD;
        if (top < PAD) {
          top = PAD;
          menu.style.maxHeight = (vh - PAD * 2) + 'px';
          menu.style.overflowY = 'auto';
        }
        menu.style.top = top + 'px';
        menu.style.left = left + 'px';
        menu.style.visibility = 'visible';
      });
    }

    document.addEventListener('click', function(e) {
      if (!e.target.closest('.actions-dropdown')) closeAll();
    });
    document.addEventListener('keydown', function(e) {
      if (e.key === 'Escape') closeAll();
    });
    window.addEventListener('scroll', closeAll, true);
    dropdowns.forEach(function(d) {
      d.addEventListener('toggle', function() {
        if (d.open) {
          positionMenu(d);
        } else {
          var menu = d.querySelector('.actions-dropdown__menu');
          if (menu) {
            menu.style.position = '';
            menu.style.top = '';
            menu.style.left = '';
            menu.style.visibility = '';
            menu.style.maxHeight = '';
            menu.style.overflowY = '';
          }
        }
      });
      var menu = d.querySelector('.actions-dropdown__menu');
      if (menu) {
        menu.addEventListener('click', function(e) {
          if (e.target.closest('a[href]') || e.target.closest('form')) {
            d.removeAttribute('open');
          }
        });
      }
    });
  }

  function init() {
    initFlashes();
    initConfirmForms();
    initDropdowns();
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
