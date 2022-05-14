import PropTypes from 'prop-types';
import { h, Component } from 'preact';
import { i18next } from '@utilities/locale';

export class Categories extends Component {
  options = () => {
    const { categoriesForSelect, categoryId } = this.props;
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

  details = () => {
    const { categoriesForDetails } = this.props;
    const rules = categoriesForDetails.map((category) => {
      const paragraphText = (
        <li>
          <strong>{category.name}:</strong> {category.rules}
        </li>
      );
      return <ul key={category.name}>{paragraphText}</ul>;
    });

    return (
      <details>
        <summary>{i18next.t('listings.form.category.summary')}</summary>
        {rules}
      </details>
    );
  };

  render() {
    const { onChange } = this.props;
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
            {this.options()}
          </select>
        </div>
        {this.details()}
      </div>
    );
  }
}

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
