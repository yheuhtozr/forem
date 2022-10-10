import {
  closeWindowModal,
  showWindowModal,
  WINDOW_MODAL_ID,
} from '@utilities/showModal';
import { request } from '@utilities/http';
import { i18next } from '@utilities/locale';

async function flagUser({ reactableType, category, reactableId, username }) {
  const body = JSON.stringify({
    category,
    reactable_type: reactableType,
    reactable_id: reactableId,
  });

  try {
    const response = await request('/reactions', {
      method: 'POST',
      body,
      credentials: 'same-origin',
    });

    const outcome = await response.json();

    if (outcome.result === 'create') {
      top.addSnackbarItem({
        message: i18next.t('flagUser.less'),
        addCloseButton: true,
      });
    } else if (outcome.result === 'destroy') {
      top.addSnackbarItem({
        message: i18next.t('flagUser.unflag'),
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
    toggleFlagBtnContent(outcome.result, username);
  } catch (error) {
    top.addSnackbarItem({
      message: error,
      addCloseButton: true,
    });
  }

  closeModal();
}

function closeModal() {
  closeWindowModal(window.parent.document);
}

function toggleFlagBtnContent(result, username) {
  const actionsPanel =
    window.parent.document.getElementById('mod-container').contentWindow
      .document;
  const flagUserBtn = actionsPanel.getElementById('toggle-flag-user-modal');

  if (result == 'create') {
    flagUserBtn.setAttribute('data-modal-title', i18next.t('profile.unflag', { user: username }));
    flagUserBtn.setAttribute(
      'data-modal-content-selector',
      '#unflag-user-modal-content',
    );
    flagUserBtn.classList.remove('c-btn--destructive');
    flagUserBtn.innerText = `Unflag ${username}`;
  } else if (result == 'destroy') {
    flagUserBtn.setAttribute('data-modal-title', i18next.t('profile.flag', { user: username }));
    flagUserBtn.setAttribute(
      'data-modal-content-selector',
      '#flag-user-modal-content',
    );
    flagUserBtn.classList.add('c-btn--destructive');
    flagUserBtn.innerText = i18next.t('profile.flag', { user: username });
  }
}

function addModalListeners() {
  const modalWindow = window.parent.document;
  const modal = modalWindow.getElementById(WINDOW_MODAL_ID);
  const confirmFlagUserRadio = modalWindow.getElementById(
    'flag-user-radio-input',
  );
  const confirmFlagUserBtn = modalWindow.getElementById(
    'confirm-flag-user-action',
  );
  const confirmUnflagUserBtn = modalWindow.getElementById(
    'confirm-unflag-user-action',
  );
  const reportLink = modalWindow.getElementById('report-inappropriate-content');
  const errorMsg = modal.querySelector('#unselected-radio-error');

  confirmFlagUserBtn?.addEventListener('click', () => {
    const { category, reactableType, userId, username } =
      confirmFlagUserBtn.dataset;
    if (confirmFlagUserRadio.checked) {
      errorMsg.innerText = '';
      flagUser({
        category,
        reactableType,
        reactableId: userId,
        username,
      });
    } else {
      errorMsg.innerText = i18next.t('flagUser.error_radio');
    }
  });

  reportLink?.addEventListener('click', (event) => {
    window.parent.document.location.href = event.target.dataset.reportAbuseLink;
  });

  confirmUnflagUserBtn?.addEventListener('click', () => {
    const { category, reactableType, userId, username } =
      confirmUnflagUserBtn.dataset;
    flagUser({
      category,
      reactableType,
      reactableId: userId,
      username,
    });
  });
}

const modalContents = new Map();

/**
 * Helper function to handle finding and caching modal content. Since our Preact modal helper works by duplicating HTML content,
 * and our modals rely on IDs to label form controls, we remove the original hidden content from the DOM to avoid ID conflicts.
 *
 * @param {string} modalContentSelector The CSS selector used to identify the correct modal content
 */
const getModalContents = (modalContentSelector) => {
  if (!modalContents.has(modalContentSelector)) {
    const modalContentElement =
      window.parent.document.querySelector(modalContentSelector);
    const modalContent = modalContentElement.innerHTML;

    modalContentElement.remove();
    modalContents.set(modalContentSelector, modalContent);
  }

  return modalContents.get(modalContentSelector);
};

export function toggleFlagUserModal(event) {
  event.preventDefault;
  const { modalTitle, modalSize, modalContentSelector } = event.target.dataset;
  showWindowModal({
    document: window.parent.document,
    modalContent: getModalContents(modalContentSelector),
    title: modalTitle,
    size: modalSize,
    onOpen: addModalListeners,
  });
}
