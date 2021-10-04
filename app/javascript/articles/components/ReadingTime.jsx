import { h } from 'preact';
import PropTypes from 'prop-types';
import { i18next } from '@utilities/locale';

export const ReadingTime = ({ readingTime, baseLang }) => {
  const div = Math.floor((readingTime || 0) / 100);
  const mod = div % 100;
  return (
    <small className="crayons-story__tertiary fs-xs mr-2 mb-2">
      <span class="whitespace-nowrap">{baseLang} &bull; </span>
      <span class="whitespace-nowrap">
        {i18next.t('articles.reading_time', {
          count: div < 1 ? 100 : div * 100 + (mod >= 50 ? 100 : 0),
        })}
      </span>
    </small>
  );
};

ReadingTime.defaultProps = {
  readingTime: null,
};

ReadingTime.propTypes = {
  readingTime: PropTypes.number,
  baseLang: PropTypes.string.isRequired,
};

ReadingTime.displayName = 'ReadingTime';
