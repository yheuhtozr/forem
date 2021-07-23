import { h } from 'preact';
import PropTypes from 'prop-types';
import { i18next } from '../../i18n/l10n';

/* global timeAgo */

export const PublishDate = ({
  readablePublishDate,
  publishedTimestamp,
  publishedAtInt,
}) => {
  const timeAgoIndicator = timeAgo({
    oldTimeInSeconds: publishedAtInt,
    formatter: (x) => x,
    maxDisplayedAge: 60 * 60 * 24 * 7,
  });

  const timeAgoText = () => {
    if (timeAgoIndicator) {
      return i18next.t('articles.timeAgo', { ago: timeAgoIndicator });
    }
    return '';
  };

  return (
    <time dateTime={publishedTimestamp}>
      {readablePublishDate}
      {timeAgoText()}
    </time>
  );
};

PublishDate.defaultProps = {
  publishedTimestamp: null,
  publishedAtInt: null,
};

PublishDate.propTypes = {
  readablePublishDate: PropTypes.string.isRequired,
  publishedTimestamp: PropTypes.string,
  publishedAtInt: PropTypes.string,
};

PublishDate.displayName = 'PublishDate';
