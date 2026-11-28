const dialog = document.querySelector('#lightbox');
const openers = document.querySelectorAll('.js-lightbox');
const close = dialog.querySelector('.close');

function openLightbox() { dialog.showModal(); }
openers.forEach((item) => {
  item.addEventListener('click', openLightbox);
  item.addEventListener('keydown', (event) => {
    if (event.key === 'Enter' || event.key === ' ') { event.preventDefault(); openLightbox(); }
  });
});
close.addEventListener('click', () => dialog.close());
dialog.addEventListener('click', (event) => { if (event.target === dialog) dialog.close(); });
