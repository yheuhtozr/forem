import PropTypes from 'prop-types';
import { h } from 'preact';
import { forwardRef } from 'preact/compat';
import { i18next } from '../i18n/l10n';

export const SearchForm = forwardRef(
  ({ searchTerm, onSearch, onSubmitSearch }, ref) => (
    <form
      action="/search"
      acceptCharset="UTF-8"
      method="get"
      onSubmit={onSubmitSearch}
    >
      <input name="utf8" type="hidden" value="✓" />
      <input
        ref={ref}
        className="crayons-header--search-input crayons-textfield"
        type="text"
        name="q"
        placeholder={i18next.t('search.placeholder')}
        autoComplete="off"
        aria-label={i18next.t('search.aria_label')}
        onKeyDown={onSearch}
        value={searchTerm}
      />
    </form>
  ),
);

SearchForm.propTypes = {
  searchTerm: PropTypes.string.isRequired,
  onSearch: PropTypes.func.isRequired,
  onSubmitSearch: PropTypes.func.isRequired,
};
