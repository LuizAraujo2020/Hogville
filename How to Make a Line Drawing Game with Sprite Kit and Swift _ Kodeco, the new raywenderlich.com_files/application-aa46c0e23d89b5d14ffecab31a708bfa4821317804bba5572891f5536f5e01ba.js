const LOAD_EVENT = window.hasOwnProperty('Turbo') ? 'turbo:load' : 'DOMContentLoaded';
document.addEventListener(LOAD_EVENT, () => {
  document.addEventListener('click', function(e) {
    const details = [...document.querySelectorAll('details[open] > details-menu')];
    details.forEach(menu => {
      const opened = menu.closest('details');
      if (!opened.contains(e.target)) {
        opened.removeAttribute('open');
      }
    })
  });
});
document.addEventListener(LOAD_EVENT, () => {
  const COOKIE_NAME = 'murakami-dismissed';

  /* Utility methods */
  const getCookie = (name) => {
    const value = `; ${document.cookie}`;
    const parts = value.split(`; ${name}=`);
    if (parts.length === 2) return parts.pop().split(';').shift();
  }

  const setCookie = (name, value, options = {}) => {
    let updatedCookie = encodeURIComponent(name) + '=' + encodeURIComponent(value);

    for (let optionKey in options) {
      updatedCookie += '; ' + optionKey;
      let optionValue = options[optionKey];
      if (optionValue !== true) {
        updatedCookie += '=' + optionValue;
      }
    }

    document.cookie = updatedCookie;
  }

  const hideElement = (element) => {
    element.classList.add('hidden');
  };

  const checkDismissed = (id) => {
    const cookieContent = getCookie(COOKIE_NAME);
    const ids = cookieContent ? cookieContent.split(',') : [];
    return ids.includes(id);
  };

  const dismissElement = (element) => {
    const id = element.dataset.murakamiDismissible;
    if (!id || id === '') { return; }

    const tld = window.location.hostname.split('.').slice(-2).join('.');
    const currentIds = getCookie(COOKIE_NAME) ? getCookie(COOKIE_NAME).split(',') : [];
    const newIds = [...currentIds, id];
    const uniqueIds = [...new Set(newIds)];
    setCookie(COOKIE_NAME, uniqueIds.join(','), { 'max-age': 60*60*24*365*10, path: '/', domain: tld, samesite: 'lax' });
    hideElement(element);
  };


  const dismissibleElements = [...document.querySelectorAll('[data-murakami-dismissible]')];
  dismissibleElements.forEach((element) => {
    const id = element.dataset.murakamiDismissible;

    if (checkDismissed(id)) {
      hideElement(element);
    }

    const buttons = [...element.querySelectorAll('[data-murakami-dismissible-button]')];
    buttons.forEach((button) => {
      button.addEventListener('click', () => {
        dismissElement(element);
      });
    });
  });
});
// This is simple script to show and hide the navigation menu on mobile
// devices. It should really be a stimulus controller, but we haven't
// really worked out how to share them from murakami.

document.addEventListener(LOAD_EVENT, () => {
  // Show/hide the menu
  const classToToggle = 'header-container-open';
  const containers = [...document.querySelectorAll('[data-mobile-nav-container')];
  const buttons = [...document.querySelectorAll('[data-mobile-nav-button]')];
  console.log(containers);
  console.log(buttons);
  buttons.forEach((button) => {
    button.addEventListener('click', () => {
      containers.forEach((container) => {
        container.classList.toggle(classToToggle);
      });
    });
  });

  // Expand/collapse the expandable items
  const expandableClassToToggle = 'dropdown-expandable-expanded';
  const expandableContainers = [...document.querySelectorAll('.dropdown-expandable')];
  expandableContainers.forEach((container) => {
    const expandableTriggers = [...container.querySelectorAll('.dropdown-line')];
    expandableTriggers.forEach((trigger) => {
      trigger.addEventListener('click', () => {
        container.classList.toggle(expandableClassToToggle);
      });
    });
  });
});
document.addEventListener(LOAD_EVENT, () => {
  [...document.querySelectorAll("input[type='search']+svg[role='clear']")].forEach((el) => {
    el.addEventListener('click', (e) => {
      if (e.target.previousElementSibling && e.target.previousElementSibling.tagName === 'INPUT') {
        e.target.previousElementSibling.value = '';
      } else if (e.target.parentElement.previousElementSibling && e.target.parentElement.previousElementSibling.tagName === 'INPUT') {
        e.target.parentElement.previousElementSibling.value = '';
      }
    });
  });
});


