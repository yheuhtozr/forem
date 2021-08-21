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

export const SearchForm = forwardRef(({ searchTerm, onSubmitSearch }, ref) => (
  <form
    action="/search"
    acceptCharset="UTF-8"
    method="get"
    onSubmit={onSubmitSearch}
    role="search"
  >
    <input name="utf8" type="hidden" value="✓" />
    <div class="crayons-fields crayons-fields--horizontal">
      <div class="crayons-field flex-1 relative">
        <input
          ref={ref}
          className="crayons-header--search-input crayons-textfield"
          type="text"
          name="q"
          placeholder="Search..."
          autoComplete="off"
          aria-label="Search term"
          value={searchTerm}
        />
        <Button
          type="submit"
          variant="ghost"
          contentType="icon-rounded"
          icon={SearchIcon}
          size="s"
          className="absolute right-2 bottom-0 top-0 m-1"
          aria-label="Search"
        />
      </div>
    </div>
  </form>
));

SearchForm.propTypes = {
  searchTerm: PropTypes.string.isRequired,
  onSubmitSearch: PropTypes.func.isRequired,
};
