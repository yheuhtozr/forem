import { h } from 'preact';
import PropTypes from 'prop-types';
import { i18next } from '../../i18n/l10n';

export const BodyMarkdown = ({ onChange, defaultValue }) => (
  <div className="crayons-field">
    <label className="crayons-field__label" htmlFor="body_markdown">
      {i18next.t('listings.form.body_markdown.label')}
    </label>
    <textarea
      className="crayons-textfield"
      id="body_markdown"
      name="listing[body_markdown]"
      maxLength="400"
      placeholder={i18next.t('common.etc')}
      value={defaultValue}
      onInput={onChange}
    />
    <p className="crayons-field__description">
      400 characters max, 12 line break max, no images allowed, *markdown is
      encouraged*. Please include a contact method if necessary.
    </p>
  </div>
);

BodyMarkdown.propTypes = {
  onChange: PropTypes.func.isRequired,
  defaultValue: PropTypes.string.isRequired,
};
