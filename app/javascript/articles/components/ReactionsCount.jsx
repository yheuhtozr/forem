import { h } from 'preact';
import { articlePropTypes } from '../../common-prop-types';
import { i18next } from '@utilities/locale';

export const ReactionsCount = ({ article }) => {
  const totalReactions = article.public_reactions_count || 0;

  if (totalReactions === 0) {
    return;
  }

  function buildIcons() {
    const reversable = article.public_reaction_categories;
    const reactionIcons = document.getElementById(
      'reaction-category-resources',
    );

    if (reversable === undefined) {
      return;
    }
    reversable.reverse();

    const icons = reversable.map((category) => {
      const path = reactionIcons?.querySelector(
        `img[data-slug=${category.slug}]`,
      )?.src;
      const alt = category.name;
      return (
        <span className="crayons_icon_container" key={category.slug}>
          <img src={path} width="18" height="18" alt={alt} />
        </span>
      );
    });

    return (
      <span className="multiple_reactions_icons_container" dir="rtl">
        {icons}
      </span>
    );
  }

  function buildCounter() {
    return (
      <span className="aggregate_reactions_counter">
        <span className="hidden s:inline" title={i18next.t('reactions.title')}>
          {i18next.t('reactions.count', { count: totalReactions })}
        </span>
      </span>
    );
  }

  return (
    <a
      href={article.path}
      className="crayons-btn crayons-btn--s crayons-btn--ghost crayons-btn--icon-left"
      data-reaction-count
      data-reactable-id={article.id}
    >
      <div className="multiple_reactions_aggregate">
        {buildIcons()}
        {buildCounter()}
      </div>
    </a>
  );
};

ReactionsCount.propTypes = {
  article: articlePropTypes.isRequired,
};

ReactionsCount.displayName = 'ReactionsCount';
