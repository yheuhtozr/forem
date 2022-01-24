import { h, render } from 'preact';
import { useState, useRef } from 'preact/hooks';
import PropTypes from 'prop-types';
import { request } from '../utilities/http';
import { i18next } from '@utilities/locale';
import { Button } from '@crayons/Button/Button';

async function confirmFlagUser({ reactableType, category, reactableId }) {
  const body = JSON.stringify({
    reactable_type: reactableType,
    category,
    reactable_id: reactableId,
  });

  try {
    const response = await request('/reactions', {
      method: 'POST',
      body,
    });

    const outcome = await response.json();

    if (outcome.result === 'create') {
      top.addSnackbarItem({
        message: i18next.t('flagUser.less'),
        addCloseButton: true,
      });
    } else if (outcome.result === null) {
      top.addSnackbarItem({
        message: i18next.t('flagUser.already'),
        addCloseButton: true,
      });
    } else {
      top.addSnackbarItem({
        message: i18next.t('flagUser.response', {
          outcome: JSON.stringify(outcome),
        }),
        addCloseButton: true,
      });
    }
  } catch (error) {
    top.addSnackbarItem({
      message: error,
      addCloseButton: true,
    });
  }

  toggleFlagUserModal();
}

/**
 * Shows or hides the flag user modal.
 */
export function toggleFlagUserModal() {
  const modalContainer = top.document.getElementsByClassName(
    'flag-user-modal-container',
  )[0];
  modalContainer.classList.toggle('hidden');

  if (!modalContainer.classList.contains('hidden')) {
    top.window.scrollTo(0, 0);
    top.document.body.style.height = '100vh';
    top.document.body.style.overflowY = 'hidden';
  } else {
    top.document.body.style.height = 'inherit';
    top.document.body.style.overflowY = 'inherit';
  }
}

/**
 * Initializes the flag user modal for the given author ID.
 *
 * @param {number} authorId
 */
export function initializeFlagUserModal(authorId) {
  // Check whether context is ModCenter or Friday-Night-Mode
  const modContainer = document.getElementById('mod-container');

  if (!modContainer) {
    return;
  }

  render(
    <FlagUserModal authorId={authorId} />,
    document.getElementsByClassName('flag-user-modal-container')[0],
  );
}

/**
 * A modal for flagging a user and their content. This can be used in the moderation
 * or on an article page.
 *
 * @param {string} props.modCenterUrl (optional) The article URL loaded when in the moderation center.
 * @param {number} props.authorId The author ID associated to the content being moderated.
 */
export function FlagUserModal({ modCenterArticleUrl, authorId }) {
  const [isConfirmButtonEnabled, enableConfirmButton] = useState(false);
  const vomitAllRef = useRef(null);

  const { communityName } = document.body.dataset;

  return (
    <div
      data-testid="flag-user-modal"
      class="crayons-modal crayons-modal--s absolute flag-user-modal"
    >
      <div class="crayons-modal__box">
        <header class="crayons-modal__box__header flag-user-modal-header">
          <h2 class="crayons-modal__box__header__title">
            {i18next.t('flagUser.heading')}
          </h2>
          <button
            type="button"
            class="crayons-btn crayons-btn--icon crayons-btn--ghost modal-header-close-icon"
            onClick={toggleFlagUserModal}
          />
        </header>
        <div class="crayons-modal__box__body">
          <div class="grid gap-4">
            <p>{i18next.t('flagUser.desc', { community: communityName }) /* TODO: unideal i18n interpolation */}</p>
            <div class="crayons-field crayons-field--radio">
              <input
                type="radio"
                id="vomit-all"
                ref={vomitAllRef}
                name="flag-user"
                class="crayons-radio"
                data-reactable-id={authorId}
                data-category="vomit"
                data-reactable-type="User"
                checked={isConfirmButtonEnabled}
                onClick={(event) => {
                  const { target } = event;

                  enableConfirmButton(target.checked);
                }}
              />
              <label htmlFor="vomit-all" class="crayons-field__label">
                {i18next.t('flagUser.vomit')}
                <p class="crayons-field__description">
                  {i18next.t('flagUser.vomit_desc')}
                </p>
              </label>
            </div>
            <p>
              <Link
                variant="branded"
                href={`/report-abuse?url=${
                  modCenterArticleUrl
                    ? `${document.location.origin}${modCenterArticleUrl}`
                    : document.location
                }`}
              >
                {i18next.t('flagUser.other')}
              </a>
            </p>
            <div>
              <Button
                destructive
                variant="primary"
                className="mr-2"
                id="confirm-flag-user-action"
                onClick={(_event) => {
                  const {
                    current: { dataset: adminVomitReaction },
                  } = vomitAllRef;

                  confirmFlagUser(adminVomitReaction);
                  enableConfirmButton(false);
                }}
                disabled={!isConfirmButtonEnabled}
              >
                {i18next.t('flagUser.confirm')}
              </Button>
              <Button
                id="cancel-flag-user-action"
                onClick={toggleFlagUserModal}
              >
                {i18next.t('flagUser.cancel')}
              </Button>
            </div>
          </div>
        </div>
      </div>
      <div
        role="presentation"
        class="crayons-modal__overlay"
        onClick={toggleFlagUserModal}
        onKeyUp={toggleFlagUserModal}
      />
    </div>
  );
}

FlagUserModal.displayName = 'FlagUserModal';
FlagUserModal.propTypes = {
  moderationUrl: PropTypes.string,
  authorId: PropTypes.number.isRequired,
};
