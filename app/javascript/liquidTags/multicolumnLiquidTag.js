export async function loadMulticolumnFix() {
  const mcClass = '.migdal-mc-table';
  const notFirefox = navigator.userAgent.toLowerCase().indexOf('firefox') <= -1;
  let max = 0;
  const widthMap = Array.from(document.querySelectorAll(mcClass)).map((t) => {
    // Wrapper: see app/services/html/parser.rb #wrap_all_tables
    t.parentElement.classList.replace(
      'table-wrapper-paragraph',
      'table-wrapper-paragraph-multicolumn',
    );
    if (notFirefox) {
      return [];
    }

    const tr_array = Array.from(t.querySelectorAll(':scope tr'));
    const td_query = ':scope > td, :scope > th';
    max = tr_array.reduce((a, b) => {
      return Math.max(a, b.querySelectorAll(td_query).length);
    }, 0);
    const widths = Array.from(
      tr_array
        .find((tr) => tr.querySelectorAll(td_query).length === max)
        .querySelectorAll(td_query),
    ).map((td) => td.offsetWidth);

    t.outerHTML = t.outerHTML
      .replace('<table class="migdal-mc-table"', '<div class="migdal-mc-table"')
      .replace(/<(tbody|thead|tfoot|tr|td|th)\b/g, '<div class="migdal-mc-$1"')
      .replace(/<\/(?:table|tbody|thead|tfoot|tr|td|th)\b/g, '</div');

    return widths;
  });

  if (notFirefox) {
    return;
  }
  document.querySelectorAll(mcClass).forEach((t, i) => {
    if (max > 0) {
      for (let nth = 1; nth <= max; nth++) {
        const col = Array.from(
          t.querySelectorAll(
            `:scope .migdal-mc-tr > .migdal-mc-td:nth-child(${nth}), :scope .migdal-mc-tr > .migdal-mc-th:nth-child(${nth})`,
          ),
        );
        for (const cell of col) {
          cell.style.width = `${widthMap[i][nth - 1] + 1}px`;
        } // +1px is needed to keep text contained in actual browser for some reason.
      }
    }

    t.classList.replace('migdal-mc-table', 'migdal-mc-table--complete');
  });
}
