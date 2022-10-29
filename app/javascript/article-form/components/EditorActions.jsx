import { h } from 'preact';
import moment from 'moment';
import PropTypes from 'prop-types';
import { Trans } from 'react-i18next';
import { useState } from 'preact/hooks';
import { Options } from './Options';
import { i18next } from '@utilities/locale';
import { ButtonNew as Button, Modal } from '@crayons';

export const EditorActions = ({
  onSaveDraft,
  onPublish,
  onClearChanges,
  published,
  publishedAtDate,
  publishedAtTime,
  schedulingEnabled,
  edited,
  version,
  passedData,
  onConfigChange,
  submitting,
  previewLoading,
}) => {
  const isVersion1 = version === 'v1';
  const isVersion2 = version === 'v2';
  const [wannaPublish, setWannaPublish] = useState(false);

  if (submitting) {
    return (
      <div className="crayons-article-form__footer">
        <Button
          variant="primary"
          className="mr-2 whitespace-nowrap"
          onClick={onPublish}
          disabled
        >
          {i18next.t(
            published && isVersion2
              ? 'editor.publishing'
              : isVersion2
              ? 'editor.saving_draft'
              : 'editor.saving',
          )}
        </Button>
      </div>
    );
  }

  const now = moment();
  const publishedAtObj = publishedAtDate
    ? moment(`${publishedAtDate} ${publishedAtTime || '00:00'}`)
    : now;
  const schedule = publishedAtObj > now;
  const wasScheduled = passedData.publishedAtWas > now;

  let saveButtonText;
  if (isVersion1) {
    saveButtonText = i18next.t('editor.save');
  } else if (schedule) {
    saveButtonText = i18next.t('editor.schedule');
  } else if (wasScheduled || !published) {
    // if the article was saved as scheduled, and the user clears publishedAt in the post options, the save button text is changed to "Publish"
    // to make it clear that the article is going to be published right away
    saveButtonText = i18next.t('editor.publish');
  } else {
    saveButtonText = i18next.t('editor.save');
  }

  return (
    <div className="crayons-article-form__footer">
      <Button
        variant="primary"
        className="mr-2 whitespace-nowrap"
        onClick={schedule ? onPublish : () => setWannaPublish(true)}
        disabled={previewLoading}
      >
        {saveButtonText}
      </Button>

      {wannaPublish && (
        <Modal
          size="s"
          title={i18next.t('editor.publishConfirm.title')}
          onClose={() => setWannaPublish(false)}
        >
          <p>
            <Trans i18nKey="editor.publishConfirm.text" />
          </p>
          <div className="pt-4">
            <Button className="mr-2" variant="danger" onClick={onPublish}>
              {i18next.t('editor.publishConfirm.yes')}
            </Button>
            <Button variant="secondary" onClick={() => setWannaPublish(false)}>
              {i18next.t('editor.publishConfirm.no')}
            </Button>
          </div>
        </Modal>
      )}

      {!(published || isVersion1) && (
        <Button
          className="mr-2 whitespace-nowrap"
          onClick={onSaveDraft}
          disabled={previewLoading}
        >
          <Trans
            i18nKey="editor.save_draft"
            // eslint-disable-next-line react/jsx-key, jsx-a11y/anchor-has-content
            components={[<span className="hidden s:inline" />]}
          />
        </Button>
      )}

      {isVersion2 && (
        <Options
          passedData={passedData}
          schedulingEnabled={schedulingEnabled}
          onConfigChange={onConfigChange}
          onSaveDraft={onSaveDraft}
          previewLoading={previewLoading}
        />
      )}

      {edited && (
        <Button
          onClick={onClearChanges}
          className="whitespace-nowrap fw-normal fs-s"
          disabled={previewLoading}
        >
          <Trans
            i18nKey="editor.revert_button"
            // eslint-disable-next-line react/jsx-key, jsx-a11y/anchor-has-content
            components={[<span className="hidden s:inline" />]}
          />
        </Button>
      )}
    </div>
  );
};

EditorActions.propTypes = {
  onSaveDraft: PropTypes.func.isRequired,
  onPublish: PropTypes.func.isRequired,
  published: PropTypes.bool.isRequired,
  publishedAtTime: PropTypes.string.isRequired,
  publishedAtDate: PropTypes.string.isRequired,
  schedulingEnabled: PropTypes.bool.isRequired,
  edited: PropTypes.bool.isRequired,
  version: PropTypes.string.isRequired,
  onClearChanges: PropTypes.func.isRequired,
  passedData: PropTypes.object.isRequired,
  onConfigChange: PropTypes.func.isRequired,
  submitting: PropTypes.bool.isRequired,
  previewLoading: PropTypes.bool.isRequired,
};

EditorActions.displayName = 'EditorActions';
