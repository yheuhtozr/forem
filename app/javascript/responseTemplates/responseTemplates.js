import { i18next } from '@utilities/locale';

function toggleTemplateTypeButton(form, e) {
  const { targetType } = e.target.dataset;
  const activeType = targetType === 'personal' ? 'moderator' : 'personal';
  e.target.classList.toggle('active');
  form
    .getElementsByClassName(`${activeType}-template-button`)[0]
    .classList.toggle('active');
  form
    .getElementsByClassName(`${targetType}-responses-container`)[0]
    .classList.toggle('hidden');
  form
    .getElementsByClassName(`${activeType}-responses-container`)[0]
    .classList.toggle('hidden');
}

const noResponsesHTML = `
<div class="mod-response-wrapper mod-response-wrapper-empty">
  <p>${i18next.t('templates.no_yet')}</p>
</div>
`;

function buildHTML(response, typeOf) {
  if (response.length === 0 && typeOf === 'personal_comment') {
    return noResponsesHTML;
  }
  if (typeOf === 'personal_comment') {
    return response
      .map((obj) => {
        const content = obj.content.replaceAll('"', '&quot;');
        return `
          <div class="mod-response-wrapper flex mb-4">
            <div class="flex-1">
              <h4>${obj.title}</h4>
              <p>${obj.content}</p>
            </div>
            <div class="pl-2">
              <button class="crayons-btn crayons-btn--secondary crayons-btn--s insert-template-button" type="button" data-content="${content}">${i18next.t('templates.insert')}</button>
            </div>
          </div>
        `;
      })
      .join('');
  }
  if (typeOf === 'mod_comment') {
    return response
      .map((obj) => {
        const content = obj.content.replaceAll('"', '&quot;');
        return `
            <div class="mod-response-wrapper mb-4 flex">
              <div class="flex-1">
                <h4>${obj.title}</h4>
                <p>${obj.content}</p>
              </div>
              <div class="flex flex-nowrap pl-2">
                <button class="crayons-btn crayons-btn--s crayons-btn--secondary moderator-submit-button m-1" type="submit" data-response-template-id="${obj.id}">${i18next.t('templates.mod')}</button>
                <button class="crayons-btn crayons-btn--s crayons-btn--outlined insert-template-button m-1" type="button" data-content="${content}">${i18next.t('templates.insert')}</button>
              </div>
            </div>
          `;
      })
      .join('');
  }
  return i18next.t('errors.sad');
}

function submitAsModerator(responseTemplateId, parentId) {
  const commentableId = document.getElementById('comment_commentable_id').value;

  fetch(`/comments/moderator_create`, {
    method: 'POST',
    headers: {
      Accept: 'application/json',
      'X-CSRF-Token': window.csrfToken,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      response_template: {
        id: responseTemplateId,
      },
      comment: {
        body_markdown: '',
        commentable_id: commentableId,
        commentable_type: 'Article',
        parent_id: parentId,
      },
    }),
  })
    .then((response) => response.json())
    .then((response) => {
      if (response.status === i18next.t('comments.messages.success')) {
        window.location.pathname = response.path;
      } else if (response.status === i18next.t('comments.messages.failure')) {
        alert(i18next.t('errors.comment'));
      } else if (response.error === 'error') {
        alert(`${response.status}`);
      }
    });
}

const confirmMsg = i18next.t('templates.mascot');

function addClickListeners(form, onTemplateSelected) {
  const responsesContainer = form.getElementsByClassName(
    'response-templates-container',
  )[0];
  const parentCommentId =
    form.id !== 'new_comment' && !form.id.includes('edit_comment');
  const insertButtons = Array.from(
    responsesContainer.getElementsByClassName('insert-template-button'),
  );
  const moderatorSubmitButtons = Array.from(
    responsesContainer.getElementsByClassName('moderator-submit-button'),
  );

  insertButtons.forEach((button) => {
    button.addEventListener('click', (event) => {
      const { content } = event.target.dataset;

      const textArea = event.target.form.querySelector('.comment-textarea');
      const textAreaReplaceable =
        textArea.value === null ||
        textArea.value === '' ||
        confirm(i18next.t('templates.replace'));

      if (textAreaReplaceable) {
        textArea.value = content;
        textArea.dispatchEvent(new Event('input', { target: textArea }));
        textArea.focus();
        onTemplateSelected();
      }
    });
  });

  moderatorSubmitButtons.forEach((button) => {
    button.addEventListener('click', (e) => {
      e.preventDefault();

      if (confirm(confirmMsg)) {
        submitAsModerator(e.target.dataset.responseTemplateId, parentCommentId);
      }
    });
  });
}

function fetchResponseTemplates(formId, onTemplateSelected) {
  const form = document.getElementById(formId);

  const typesOf = [
    ['personal_comment', 'personal-responses-container'],
    ['mod_comment', 'moderator-responses-container'],
  ];

  fetch(`/response_templates`, {
    method: 'GET',
    headers: {
      Accept: 'application/json',
      'X-CSRF-Token': window.csrfToken,
      'Content-Type': 'application/json',
    },
  })
    .then((response) => response.json())
    .then((response) => {
      form.querySelector('img.loading-img').classList.toggle('hidden');

      let revealed;
      const topLevelData = document.getElementById('response-templates-data');

      for (const typesOfContainers of typesOf) {
        const [typeOf, containedIn] = typesOfContainers;

        if (typeof response[typeOf] != 'undefined') {
          const dataContainer = form.getElementsByClassName(containedIn)[0];
          dataContainer.innerHTML = buildHTML(response[typeOf], typeOf);

          if (revealed) {
            topLevelData.classList.add(typeOf);
            dataContainer.classList.add('hidden');
            prepareHeaderButtons(form);
          } else {
            revealed = dataContainer;
            dataContainer.classList.remove('hidden');
            topLevelData.classList.add(typeOf);
          }

          topLevelData.innerHTML = dataContainer.parentElement.innerHTML;
        }
      }

      addClickListeners(form, onTemplateSelected);
    });
}

function prepareHeaderButtons(form) {
  const personalTemplateButton = form.getElementsByClassName(
    'personal-template-button',
  )[0];
  const modTemplateButton = form.getElementsByClassName(
    'moderator-template-button',
  )[0];

  personalTemplateButton.addEventListener('click', (e) => {
    toggleTemplateTypeButton(form, e);
  });
  personalTemplateButton.classList.remove('hidden');

  modTemplateButton.addEventListener('click', (e) => {
    toggleTemplateTypeButton(form, e);
  });
  modTemplateButton.classList.remove('hidden');
}

function copyData(responsesContainer) {
  responsesContainer.innerHTML = document.getElementById(
    'response-templates-data',
  ).innerHTML;
}

function loadData(form, onTemplateSelected) {
  form.querySelector('img.loading-img').classList.toggle('hidden');
  fetchResponseTemplates(form.id, onTemplateSelected);
}

/**
 * This helper function makes sure the correct templates are inserted into the UI next to the given comment form.
 *
 * @param {HTMLElement} form The relevant comment form
 * @param {Function} onTemplateSelected Callback for when a template is inserted
 */
export function populateTemplates(form, onTemplateSelected) {
  const responsesContainer = form.getElementsByClassName(
    'response-templates-container',
  )[0];
  const topLevelData = document.getElementById('response-templates-data');
  const dataFetched = topLevelData.innerHTML !== '';

  if (dataFetched) {
    copyData(responsesContainer);
    addClickListeners(form, onTemplateSelected);
  } else if (!dataFetched) {
    loadData(form, onTemplateSelected);
  }

  const hasBothTemplates =
    topLevelData.classList.contains('personal_comment') &&
    topLevelData.classList.contains('mod_comment');

  if (hasBothTemplates) {
    form
      .getElementsByClassName('moderator-template-button')[0]
      .classList.remove('hidden');
    form
      .getElementsByClassName('personal-template-button')[0]
      .classList.remove('hidden');

    prepareHeaderButtons(form);
  } else {
    form
      .getElementsByClassName('moderator-template-button')[0]
      .classList.add('hidden');
    form
      .getElementsByClassName('personal-template-button')[0]
      .classList.add('hidden');
  }
}
