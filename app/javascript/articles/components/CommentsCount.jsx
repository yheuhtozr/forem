import { h } from 'preact';
import PropTypes from 'prop-types';
import { i18next } from '../../i18n/l10n';
import { Button } from '../../crayons/Button';

export const CommentsCount = ({ count, articlePath }) => {
  const commentsSVG = () => (
    <svg
      className="crayons-icon"
      width="24"
      height="24"
      xmlns="http://www.w3.org/2000/svg"
    >
      <path d="M10.5 5h3a6 6 0 110 12v2.625c-3.75-1.5-9-3.75-9-8.625a6 6 0 016-6zM12 15.5h1.5a4.501 4.501 0 001.722-8.657A4.5 4.5 0 0013.5 6.5h-3A4.5 4.5 0 006 11c0 2.707 1.846 4.475 6 6.36V15.5z" />
    </svg>
  );

  if (count > 0) {
    return (
      <Button
        variant="ghost"
        size="s"
        contentType="icon-left"
        url={`${articlePath}#comments`}
        icon={commentsSVG}
        tagName="a"
      >
        <span
          title={i18next.t('comments.number')}
          // eslint-disable-next-line react/no-danger
          dangerouslySetInnerHTML={{
            __html: i18next.t('comments.count', {
              count,
              start: '<span className="hidden s:inline">',
              end: '</span>',
            }),
          }}
        />
      </Button>
    );
  }
  if (count === 0) {
    return (
      <Button
        variant="ghost"
        size="s"
        contentType="icon-left"
        url={`${articlePath}#comments`}
        icon={commentsSVG}
        tagName="a"
        data-testid="add-a-comment"
      >
        <span className="inline s:hidden">0</span>
        <span className="hidden s:inline">{i18next.t('comments.empty')}</span>
      </Button>
    );
  }

  return null;
};

CommentsCount.defaultProps = {
  count: 0,
};

CommentsCount.propTypes = {
  count: PropTypes.number,
  articlePath: PropTypes.string.isRequired,
};

CommentsCount.displayName = 'CommentsCount';
