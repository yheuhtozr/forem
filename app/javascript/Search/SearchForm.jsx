import PropTypes from 'prop-types';
import { h } from 'preact';
import { forwardRef } from 'preact/compat';
import { i18next } from '@utilities/locale';
import { ButtonNew as Button } from '@crayons';
import SearchIcon from '@images/search.svg';

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
          placeholder={i18next.t('search.placeholder')}
          autoComplete="off"
          aria-label={i18next.t('search.aria_label')}
          value={searchTerm}
        />
        <Button
          type="submit"
          icon={SearchIcon}
          className="absolute inset-px left-auto mt-0 py-0"
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
