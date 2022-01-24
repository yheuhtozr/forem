import PropTypes from 'prop-types';
import { h } from 'preact';
import { i18next } from '@utilities/locale';
import { Link } from '@crayons';

export const ActionButtons = ({ isDraft, editUrl, deleteConfirmUrl }) => {
  return (
    <div className="listing-row-actions flex">
      {isDraft && (
        <Link block href={editUrl}>
          {i18next.t('listings.actions.delete')}
        </Link>
      )}
      <Link block href={editUrl}>
        {i18next.t('listings.actions.edit')}
      </Link>
      <Link block href={deleteConfirmUrl}>
        {i18next.t('listings.actions.delete')}
      </Link>
    </div>
  );
};

ActionButtons.propTypes = {
  isDraft: PropTypes.bool.isRequired,
  editUrl: PropTypes.string.isRequired,
  deleteConfirmUrl: PropTypes.string.isRequired,
};
