export async function loadLeipzig() {
  /* global Leipzig  */
  const glossLiquidTags = document.getElementsByClassName('ltag_gloss');
  if (glossLiquidTags.length <= 0) {
    return;
  }

  const lzscript = document.createElement('script');
  lzscript.src = '/javascripts/leipzig.min.js';
  document.body.appendChild(lzscript);
  lzscript.onload = () => {
    Leipzig('.ltag_gloss', { lastLineFree: false }).gloss();
    while (glossLiquidTags.length) {
      glossLiquidTags[0].className = 'ltag_gloss--complete';
    }
  };
}
