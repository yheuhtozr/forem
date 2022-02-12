import { h, Fragment } from 'preact';
import ahoy from 'ahoy.js';
import PropTypes from 'prop-types';
import { i18next } from '@utilities/locale';
import { Link } from '@crayons';

export const TagsFollowed = ({ tags = [] }) => {
  const trackSidebarTagClick = (event) => {
    // Temporary Ahoy Stats for usage reports
    ahoy.track('Tag sidebar click', { option: event.target.href });
  };

  return (
    <Fragment>
      {tags.map(({ name, id, points }) =>
        // NOTE: points are the calculated points of a Tag.  See Tag#points for more discussion.
        points >= 0 ? (
          <Link
            key={id}
            title={i18next.t('main.tag', { tag: name })}
            onClick={trackSidebarTagClick}
            block
            href={`/t/${name}`}
          >
            {`#${name}`}
          </Link>
        ) : null,
      )}
    </Fragment>
  );
};

TagsFollowed.displayName = 'TagsFollowed';
TagsFollowed.propTypes = {
  tags: PropTypes.arrayOf(
    PropTypes.shape({
      id: PropTypes.number.isRequired,
      name: PropTypes.string.isRequired,
      points: PropTypes.number.isRequired,
    }),
  ),
};
