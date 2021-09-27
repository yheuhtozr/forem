import { h } from 'preact';
import PropTypes from 'prop-types';
import { Trans } from 'react-i18next';
import { i18next, locale } from '../../i18n/l10n';
import { Dropdown, Button } from '@crayons';

const Icon = () => (
  <svg
    width="24"
    className="crayons-icon"
    height="24"
    viewBox="0 0 24 24"
    xmlns="http://www.w3.org/2000/svg"
    role="img"
    aria-labelledby="75abcb76478519ca4eb9"
  >
    <title id="75abcb76478519ca4eb9">{i18next.t('editor.options.title')}</title>
    <path d="M12 1l9.5 5.5v11L12 23l-9.5-5.5v-11L12 1zm0 2.311L4.5 7.653v8.694l7.5 4.342 7.5-4.342V7.653L12 3.311zM12 16a4 4 0 110-8 4 4 0 010 8zm0-2a2 2 0 100-4 2 2 0 000 4z" />
  </svg>
);

/**
 * Component comprising a trigger button and dropdown with additional post options.
 *
 * @param {Object} props
 * @param {Object} props.passedData The current post options data
 * @param {Function} props.onSaveDraft Callback for when the post draft is saved
 * @param {Function} props.onConfigChange Callback for when the config options have changed
 */
export const Options = ({
  passedData: {
    published = false,
    allSeries = [],
    canonicalUrl = '',
    series = '',
    baseLang = '',
    allLangs = {},
  },
  onSaveDraft,
  onConfigChange,
}) => {
  let publishedField = '';
  let existingSeries = '';
  let existingLangs = '';

  if (allSeries.length > 0) {
    const seriesNames = allSeries.map((name, index) => {
      return (
        <option key={`series-${index}`} value={name}>
          {name}
        </option>
      );
    });
    existingSeries = (
      <div className="crayons-field__description">
        {i18next.t('editor.options.series.existing')}
        <select
          value=""
          name="series"
          className="crayons-select"
          onInput={onConfigChange}
          required
          aria-label={i18next.t('editor.options.series.aria_label')}
        >
          <option value="" disabled>
            {i18next.t('editor.options.series.select')}
          </option>
          {seriesNames}
        </select>
      </div>
    );
  }

  if (Object.keys(allLangs).length > 0) {
    const mapper = (sorted) => {
      return sorted.map((a) => {
        const [code, name] = a;
        return (
          <option key={`baseLang-${code}`} value={code}>
            {name} [{code}]
          </option>
        );
      });
    };
    const sorter = (a, b) => {
      return a[1].localeCompare(b[1], locale);
    };
    const miscSet = {};
    const siteSet = {};
    const specSet = {};
    const CLA3Set = {};
    const siteCodes = ['en-us', 'ja'];
    const specCodes = ['mul', 'und', 'zxx'];
    const dropCodes = ['mis'];
    Object.entries(allLangs).forEach(([code, name]) => {
      if (siteCodes.includes(code)) {
        siteSet[code] = name;
      } else if (specCodes.includes(code)) {
        specSet[code.slice(0, 3)] = name;
      } else if (code.startsWith('x-v3-')) {
        CLA3Set[code] = name;
      } else if (dropCodes.includes(code)) {
        // discard
      } else {
        miscSet[code] = name;
      }
    });
    existingLangs = (
      <div className="crayons-field__description">
        {i18next.t('editor.options.lang.existing')}
        <select
          value=""
          name="baseLang"
          className="crayons-select"
          onInput={onConfigChange}
          required
          aria-label={i18next.t('editor.options.lang.aria_label')}
        >
          <option value="" disabled>
            {i18next.t('editor.options.lang.select')}
          </option>
          <optgroup label={i18next.t('editor.options.lang.site')}>
            {mapper(Object.entries(siteSet).sort(sorter))}
          </optgroup>
          <optgroup label={i18next.t('editor.options.lang.cla')}>
            {mapper(Object.entries(CLA3Set).sort(sorter))}
          </optgroup>
          <optgroup label={i18next.t('editor.options.lang.special')}>
            {mapper(Object.entries(specSet).sort(sorter))}
          </optgroup>
          <optgroup label={i18next.t('editor.options.lang.others')}>
            {mapper(Object.entries(miscSet).sort(sorter))}
          </optgroup>
        </select>
      </div>
    );
  }

  if (published) {
    publishedField = (
      <div data-testid="options__danger-zone" className="crayons-field mb-6">
        <div className="crayons-field__label color-accent-danger">
          {i18next.t('common.danger')}
        </div>
        <Button variant="danger" onClick={onSaveDraft}>
          {i18next.t('editor.options.unpublish')}
        </Button>
      </div>
    );
  }
  return (
    <div className="s:relative">
      <Button
        id="post-options-btn"
        variant="ghost"
        contentType="icon"
        icon={Icon}
        title={i18next.t('editor.options.title')}
      />

      <Dropdown
        triggerButtonId="post-options-btn"
        dropdownContentId="post-options-dropdown"
        dropdownContentCloseButtonId="post-options-done-btn"
        className="bottom-2 s:bottom-100 left-2 s:left-0 right-2 s:left-auto"
      >
        <h3 className="mb-6">{i18next.t('editor.options.heading')}</h3>
        <div className="crayons-field mb-6">
          <label htmlFor="canonicalUrl" className="crayons-field__label">
            {i18next.t('editor.options.url.label')}
          </label>
          <p className="crayons-field__description">
            <Trans i18nKey="editor.options.url.desc"
              // eslint-disable-next-line react/jsx-key
              components={[<code />]}
            />
          </p>
          <input
            type="text"
            value={canonicalUrl}
            className="crayons-textfield"
            placeholder="https://yoursite.com/post-title"
            name="canonicalUrl"
            onKeyUp={onConfigChange}
            id="canonicalUrl"
          />
        </div>
        <div className="crayons-field mb-6">
          <label htmlFor="series" className="crayons-field__label">
            {i18next.t('editor.options.series.label')}
          </label>
          <p className="crayons-field__description">
            {i18next.t('editor.options.series.desc')}
          </p>
          <input
            type="text"
            value={series}
            className="crayons-textfield"
            name="series"
            onKeyUp={onConfigChange}
            id="series"
            placeholder={i18next.t('common.etc')}
          />
          {existingSeries}
        </div>
        <div className="crayons-field mb-6">
          <label htmlFor="baseLang" className="crayons-field__label">
            {i18next.t('editor.options.lang.label')}
          </label>
          <p
            className="crayons-field__description"
            // eslint-disable-next-line react/no-danger
            dangerouslySetInnerHTML={{
              __html: i18next.t('editor.options.lang.desc', {
                interpolation: { escapeValue: false },
              }),
            }}
          />
          <input
            type="text"
            value={baseLang}
            className="crayons-textfield"
            placeholder="en-GB-oed"
            name="baseLang"
            onKeyUp={onConfigChange}
            id="baseLang"
          />
          {existingLangs}
        </div>
        {publishedField}
        <Button
          id="post-options-done-btn"
          className="w-100"
          data-content="exit"
        >
          {i18next.t('editor.options.done')}
        </Button>
      </Dropdown>
    </div>
  );
};

Options.propTypes = {
  passedData: PropTypes.shape({
    published: PropTypes.bool.isRequired,
    allSeries: PropTypes.array.isRequired,
    canonicalUrl: PropTypes.string.isRequired,
    series: PropTypes.string.isRequired,
    baseLang: PropTypes.string.isRequired,
    allLangs: PropTypes.object.isRequired,
  }).isRequired,
  onSaveDraft: PropTypes.func.isRequired,
  onConfigChange: PropTypes.func.isRequired,
};

Options.displayName = 'Options';
