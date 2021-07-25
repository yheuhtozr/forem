import { h } from 'preact';
import {
  useState,
  useEffect,
  useMemo,
  useRef,
  useLayoutEffect,
} from 'preact/hooks';
import PropTypes from 'prop-types';
import { i18next } from '../i18n/l10n';
import { useTextAreaAutoResize } from '@utilities/textAreaUtils';

export const Compose = ({
  handleKeyDown,
  handleKeyDownEdit,
  handleSubmitOnClick,
  handleSubmitOnClickEdit,
  handleMention,
  handleKeyUp,
  startEditing,
  markdownEdited,
  editMessageMarkdown,
  handleEditMessageClose,
  handleFilePaste,
  activeChannelName,
}) => {
  const [value, setValue] = useState('');
  const textAreaRef = useRef(null);

  const { setTextArea } = useTextAreaAutoResize();

  useLayoutEffect(() => {
    if (textAreaRef.current) {
      setTextArea(textAreaRef.current);
    }
  }, [setTextArea]);

  useEffect(() => {
    if (!markdownEdited && startEditing) {
      setValue(editMessageMarkdown);
    }
  }, [markdownEdited, startEditing, editMessageMarkdown]);

  const onKeyDown = (event) => {
    const shiftPressed = event.shiftKey;
    if (startEditing) handleKeyDownEdit(event);
    else handleKeyDown(event);

    if (event.keyCode === 13 && !shiftPressed) {
      event.preventDefault();
      setValue('');
    }
  };

  const placeholder = useMemo(
    () =>
      startEditing
        ? i18next.t('chat.compose.lets')
        : i18next.t('chat.compose.placeholder', { channel: activeChannelName }),
    [startEditing, activeChannelName],
  );
  const label = useMemo(
    () => i18next.t(`chat.compose.${startEditing ? 'lets' : 'aria_label'}`),
    [startEditing],
  );
  const saveButtonText = useMemo(
    () => i18next.t(`chat.compose.${startEditing ? 'save' : 'send'}`),
    [startEditing],
  );

  return (
    <div className="compose__outer__container">
      <div
        className={
          startEditing ? 'composer-container__edit' : 'messagecomposer'
        }
      >
        <textarea
          ref={textAreaRef}
          data-gramm_editor="false"
          className={
            startEditing
              ? 'crayons-textfield composer-textarea__edit'
              : 'crayons-textfield composer-textarea'
          }
          id="messageform"
          data-testid="messageform"
          placeholder={placeholder}
          onKeyDown={onKeyDown}
          onKeyPress={handleMention}
          onKeyUp={handleKeyUp}
          onPaste={handleFilePaste}
          maxLength="1000"
          value={value}
          onInput={(event) => setValue(event.target.value)}
          aria-label={label}
        />
        <div className="composer-btn-group">
          <button
            type="button"
            className={
              startEditing
                ? 'composer-submit composer-submit__edit crayons-btn'
                : 'crayons-btn composer-submit'
            }
            onClick={(event) => {
              if (startEditing) handleSubmitOnClickEdit(event);
              else handleSubmitOnClick(event);

              setValue('');
            }}
          >
            {saveButtonText}
          </button>
          {startEditing && (
            <button
              type="button"
              className="composer-close__edit crayons-btn crayons-btn--secondary"
              onClick={(event) => {
                handleEditMessageClose(event);
                setValue('');
              }}
            >
              {i18next.t('chat.compose.close')}
            </button>
          )}
        </div>
      </div>
    </div>
  );
};

Compose.propTypes = {
  handleKeyDown: PropTypes.func.isRequired,
  handleKeyDownEdit: PropTypes.func.isRequired,
  handleSubmitOnClick: PropTypes.func.isRequired,
  handleSubmitOnClickEdit: PropTypes.func.isRequired,
  handleMention: PropTypes.func.isRequired,
  handleKeyUp: PropTypes.func.isRequired,
  startEditing: PropTypes.bool.isRequired,
  markdownEdited: PropTypes.bool.isRequired,
  editMessageMarkdown: PropTypes.string.isRequired,
  handleEditMessageClose: PropTypes.func.isRequired,
  handleFilePaste: PropTypes.func.isRequired,
  activeChannelName: PropTypes.string.isRequired,
};
