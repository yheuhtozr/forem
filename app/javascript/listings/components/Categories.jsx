import PropTypes from 'prop-types';
import { h } from 'preact';
import { Trans } from 'react-i18next';
import { i18next } from '@utilities/locale';

export const Categories = ({
  categoriesForDetails,
  onChange,
  categoriesForSelect,
  categoryId,
}) => {
  const options = () => {
    return categoriesForSelect.map(([text, slug, id]) => {
      // Array example: ["Conference CFP (1 Credit)", "cfp", "1"]
      if (categoryId === id) {
        return (
          <option key={id} value={id} data-slug={slug} selected>
            {text}
          </option>
        );
      }
      return (
        <option key={id} value={id} data-slug={slug}>
          {text}
        </option>
      );
    });
  };

  const details = () => {
    return (
      <details>
        <summary>{i18next.t('listings.form.category.summary')}</summary>
        {categoriesForDetails.map((category) => {
          return (
            <ul key={category.name}>
              <li>
                <Trans
                  i18nKey="listings.form.category.details"
                  values={{ name: category.name, rules: category.rules }}
                />
              </li>
            </ul>
          );
        })}
      </details>
    );
  };

  return (
    <div>
      <div className="crayons-field mb-4">
        <label className="crayons-field__label" htmlFor="category">
          {i18next.t('listings.form.category.label')}
        </label>
        <select
          id="category"
          className="crayons-select"
          name="listing[listing_category_id]"
          onChange={onChange}
          onBlur={onChange}
        >
          {options()}
        </select>
      </div>
      {details()}
    </div>
  );
};

Categories.propTypes = {
  categoriesForSelect: PropTypes.arrayOf(PropTypes.array).isRequired,
  categoriesForDetails: PropTypes.arrayOf(
    PropTypes.shape({
      name: PropTypes.string,
      rules: PropTypes.string,
    }),
  ).isRequired,
  categoryId: PropTypes.string.isRequired,
  onChange: PropTypes.func.isRequired,
};
