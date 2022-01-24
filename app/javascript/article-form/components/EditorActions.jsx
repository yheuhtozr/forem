import { h } from 'preact';
import PropTypes from 'prop-types';
import { Trans } from 'react-i18next';
import { useState } from 'preact/hooks';
import { Options } from './Options';
import { Button, Modal } from '@crayons';
import { i18next } from '@utilities/locale';

export const EditorActions = ({
  onSaveDraft,
  onPublish,
  onClearChanges,
  published,
  edited,
  version,
  passedData,
  onConfigChange,
  submitting,
}) => {
  const isVersion1 = version === 'v1';
  const isVersion2 = version === 'v2';
  const [wannaPublish, setWannaPublish] = useState(false);

  if (submitting) {
    return (
      <div className="crayons-article-form__footer">
        <Button className="mr-2 whitespace-nowrap" onClick={onPublish} disabled>
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

  return (
    <div className="crayons-article-form__footer">
      <Button
        className="mr-2 whitespace-nowrap"
        onClick={() => setWannaPublish(true)}
      >
        {i18next.t(published || isVersion1 ? 'editor.save' : 'editor.publish')}
      </Button>

      {wannaPublish && (
        <Modal
          size="s"
          title={i18next.t('editor.publishConfirm.title')}
          onClose={() => setWannaPublish(false)}
        >
          <p>{i18next.t('editor.publishConfirm.text')}</p>
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
          variant="secondary"
          className="mr-2 whitespace-nowrap"
          onClick={onSaveDraft}
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
          onConfigChange={onConfigChange}
          onSaveDraft={onSaveDraft}
        />
      )}

      {edited && (
        <Button
          onClick={onClearChanges}
          className="whitespace-nowrap fw-normal fs-s"
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
  edited: PropTypes.bool.isRequired,
  version: PropTypes.string.isRequired,
  onClearChanges: PropTypes.func.isRequired,
  passedData: PropTypes.object.isRequired,
  onConfigChange: PropTypes.func.isRequired,
  submitting: PropTypes.bool.isRequired,
};

EditorActions.displayName = 'EditorActions';
