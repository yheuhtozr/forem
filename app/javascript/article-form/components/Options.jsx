import { h } from 'preact';
import PropTypes from 'prop-types';
import { Trans } from 'react-i18next';
import moment from 'moment';
import { i18next, locale } from '@utilities/locale';
import { Dropdown, ButtonNew as Button } from '@crayons';
import CogIcon from '@images/cog.svg';

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
    publishedAtDate = '',
    publishedAtTime = '',
    publishedAtWas = '',
    timezone = Intl.DateTimeFormat().resolvedOptions().timeZone,
    allSeries = [],
    canonicalUrl = '',
    series = '',
    baseLang = '',
    allLangs = {},
  },
  schedulingEnabled,
  onSaveDraft,
  onConfigChange,
  previewLoading,
}) => {
  let publishedField = '';
  let existingSeries = '';
  let existingLangs = '';
  let publishedAtField = '';

  const wasScheduled = publishedAtWas && moment(publishedAtWas) > moment();
  // allow to edit published at if it was not set earlier or if it's in the future
  const editablePublishedAt = !publishedAtWas || wasScheduled;

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
    if (wasScheduled) {
      publishedField = (
        <div data-testid="options__danger-zone" className="crayons-field mb-6">
          <Button
            className="c-btn c-btn--secondary w-100"
            variant="primary"
            onClick={onSaveDraft}
          >
            {i18next.t('editor.options.to_draft')}
          </Button>
        </div>
      );
    } else {
      publishedField = (
        <div data-testid="options__danger-zone" className="crayons-field mb-6">
          <div className="crayons-field__label color-accent-danger">
            {i18next.t('common.danger')}
          </div>
          <Button variant="primary" destructive onClick={onSaveDraft}>
            {i18next.t('editor.options.unpublish')}
          </Button>
        </div>
      );
    }
  }

  if (schedulingEnabled && editablePublishedAt) {
    const currentDate = moment().format('YYYY-MM-DD');
    publishedAtField = (
      <div className="crayons-field mb-6">
        <label htmlFor="publishedAtDate" className="crayons-field__label">
          {i18next.t('editor.options.schedule.label')}
        </label>
        <input
          aria-label={i18next.t('editor.options.schedule.aria_label')}
          type="date"
          min={currentDate}
          value={publishedAtDate} // ""
          className="crayons-textfield"
          name="publishedAtDate"
          onChange={onConfigChange}
          id="publishedAtDate"
          placeholder={i18next.t('common.etc')}
        />
        <input
          aria-label={i18next.t('editor.options.schedule.aria_label')}
          type="time"
          value={publishedAtTime} // "18:00"
          className="crayons-textfield"
          name="publishedAtTime"
          onChange={onConfigChange}
          id="publishedAtTime"
          placeholder={i18next.t('common.etc')}
        />
        <input
          type="hidden"
          value={timezone} // "Asia/Magadan"
          className="crayons-textfield"
          name="timezone"
          id="timezone"
          placeholder={i18next.t('common.etc')}
        />
      </div>
    );
  }

  return (
    <div className="s:relative">
      <Button
        id="post-options-btn"
        icon={CogIcon}
        title={i18next.t('editor.options.title')}
        aria-label={i18next.t('editor.options.title')}
        disabled={previewLoading}
      />

      <Dropdown
        triggerButtonId="post-options-btn"
        dropdownContentId="post-options-dropdown"
        dropdownContentCloseButtonId="post-options-done-btn"
        className="reverse left-2 s:left-0 right-2 s:left-auto p-4"
      >
        <h3 className="mb-6">{i18next.t('editor.options.heading')}</h3>
        <div className="crayons-field mb-6">
          <label htmlFor="canonicalUrl" className="crayons-field__label">
            {i18next.t('editor.options.url.label')}
          </label>
          <p className="crayons-field__description">
            <Trans i18nKey="editor.options.url.desc" />
          </p>
          <input
            type="text"
            value={canonicalUrl}
            className="crayons-textfield"
            placeholder="https://yoursite.com/post-title"
            name="canonicalUrl"
            onKeyUp={onConfigChange}
            onInput={onConfigChange}
            id="canonicalUrl"
          />
        </div>
        {publishedAtField}
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
          <p className="crayons-field__description">
            <Trans i18nKey="editor.options.lang.desc" />
          </p>
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
          variant="secondary"
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
    publishedAtDate: PropTypes.string.isRequired,
    publishedAtTime: PropTypes.string.isRequired,
    publishedAtWas: PropTypes.string.isRequired,
    timezone: PropTypes.string.isRequired,
    allSeries: PropTypes.array.isRequired,
    canonicalUrl: PropTypes.string.isRequired,
    series: PropTypes.string.isRequired,
    baseLang: PropTypes.string.isRequired,
    allLangs: PropTypes.object.isRequired,
  }).isRequired,
  schedulingEnabled: PropTypes.bool.isRequired,
  onSaveDraft: PropTypes.func.isRequired,
  onConfigChange: PropTypes.func.isRequired,
  previewLoading: PropTypes.bool.isRequired,
};

Options.displayName = 'Options';
