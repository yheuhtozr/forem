import { h } from 'preact';
import PropTypes from 'prop-types';
import { i18next } from '../../i18n/l10n';

export const ReadingTime = ({ readingTime }) => {
  const div = Math.floor((readingTime || 0) / 100);
  const mod = div % 100;
  return (
    <small className="crayons-story__tertiary fs-xs mr-2">
      なんとか語<br />
      {i18next.t('articles.reading_time', {
        count: (div < 1 ? 100 : div * 100 + (mod >= 50 ? 100 : 0)),
      })}
    </small>
  );
};

ReadingTime.defaultProps = {
  readingTime: null,
};

ReadingTime.propTypes = {
  readingTime: PropTypes.number,
};

ReadingTime.displayName = 'ReadingTime';
