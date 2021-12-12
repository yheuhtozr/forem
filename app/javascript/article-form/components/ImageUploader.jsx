/* global Runtime */

import { Fragment, h } from 'preact';
import { useReducer, useEffect, useState } from 'preact/hooks';
import { generateMainImage } from '../actions';
import { validateFileInputs } from '../../packs/validateFileInputs';
import { addSnackbarItem } from '../../Snackbar';
import { ClipboardButton } from './ClipboardButton';
import { Button, Spinner } from '@crayons';
import { i18next } from '@utilities/locale';

const ImageIcon = () => (
  <svg
    width="24"
    height="24"
    viewBox="0 0 24 24"
    className="crayons-icon"
    xmlns="http://www.w3.org/2000/svg"
    role="img"
    aria-hidden="true"
  >
    <title id="a17qec5pfhrwzk9w4kg0tp62v27qqu9t">
      {i18next.t('editor.image.icon')}
    </title>
    <path d="M20 5H4v14l9.292-9.294a1 1 0 011.414 0L20 15.01V5zM2 3.993A1 1 0 012.992 3h18.016c.548 0 .992.445.992.993v16.014a1 1 0 01-.992.993H2.992A.993.993 0 012 20.007V3.993zM8 11a2 2 0 110-4 2 2 0 010 4z" />
  </svg>
);

const CancelIcon = () => (
  <svg
    width="24"
    height="24"
    viewBox="0 0 24 24"
    className="crayons-icon cancel"
    xmlns="http://www.w3.org/2000/svg"
    role="img"
    aria-hidden="true"
  >
    <title id="as1mn15llu5e032u2pgzlc6yhvss2myk">
      {i18next.t('editor.image.cancel')}
    </title>
    <path d="M12 10.586l4.95-4.95 1.414 1.414-4.95 4.95 4.95 4.95-1.414 1.414-4.95-4.95-4.95 4.95-1.414-1.414 4.95-4.95-4.95-4.95L7.05 5.636l4.95 4.95z" />
  </svg>
);

const SpinnerOrCancel = () => (
  <span className="spinner-or-cancel">
    <Spinner />
    <CancelIcon />
  </span>
);

ImageIcon.displayName = 'ImageIcon';

function imageUploaderReducer(state, action) {
  const { type, payload } = action;

  switch (type) {
    case 'uploading_image':
      return {
        ...state,
        uploadErrorMessage: null,
        uploadingImage: true,
        insertionImageUrls: [],
      };

    case 'upload_error':
      return {
        ...state,
        insertionImageUrls: [],
        uploadErrorMessage: payload.errorMessage,
        uploadingImage: false,
      };

    case 'upload_image_success':
      return {
        ...state,
        insertionImageUrls: payload.insertionImageUrls,
        uploadingImage: false,
        uploadErrorMessage: null,
      };

    default:
      return state;
  }
}

function initNativeImagePicker(e) {
  e.preventDefault();
  window.ForemMobile?.injectNativeMessage('imageUpload', {
    action: 'imageUpload',
  });
}

const NativeIosV1ImageUpload = ({ uploadingImage }) => (
  <Fragment>
    {!uploadingImage && (
      <Button
        aria-label="Upload an image"
        className="mr-2 fw-normal"
        variant="ghost"
        contentType="icon-left"
        icon={ImageIcon}
        onClick={initNativeImagePicker}
      >
        {i18next.t('editor.image.text')}
      </Button>
    )}
  </Fragment>
);

/**
 * The V2 editor uses a toolbar button press to trigger a visually hidden file input.
 *
 * @param {object} props
 * @param {object} props.buttonProps Any props to be added to the trigger button
 * @param {function} props.handleInsertionImageUpload Callback to handle image upload
 * @param {boolean} props.uploadingImage Is an image currently being uploaded
 * @param {boolean} props.useNativeUpload Should iOS native upload functionality be used
 * @param {function} props.handleNativeMessage Callback for iOS native upload message handling
 * @param {string} props.uploadErrorMessage Error message to be displayed
 *
 */
const V2EditorImageUpload = ({
  buttonProps,
  handleInsertionImageUpload,
  uploadingImage,
  useNativeUpload,
  handleNativeMessage,
  uploadErrorMessage,
}) => {
  useEffect(() => {
    if (uploadErrorMessage) {
      addSnackbarItem({
        message: uploadErrorMessage,
        addCloseButton: true,
      });
    }
  }, [uploadErrorMessage]);

  const [abortRequestController, setAbortRequestController] = useState(null);

  const startNewRequest = (e) => {
    const controller = new AbortController();
    setAbortRequestController(controller);
    handleInsertionImageUpload(e, controller.signal);
  };

  const cancelRequest = () => {
    abortRequestController.abort();
    setAbortRequestController(null);
  };

  const { tooltip: actionTooltip } = buttonProps;

  return (
    <Fragment>
      {useNativeUpload ? (
        <input
          type="hidden"
          id="native-image-upload-message"
          value=""
          onChange={handleNativeMessage}
        />
      ) : (
        <input
          type="file"
          tabindex="-1"
          aria-label={i18next.t('editor.image.aria_label')}
          id="image-upload-field"
          onChange={startNewRequest}
          className="screen-reader-only"
          accept="image/*"
          data-max-file-size-mb="25"
        />
      )}
      {uploadingImage ? (
        <Button
          {...buttonProps}
          icon={SpinnerOrCancel}
          onClick={cancelRequest}
          aria-label={i18next.t('editor.image.aria_cancel')}
          tooltip={i18next.t('editor.image.title_cancel')}
        />
      ) : (
        <Button
          {...buttonProps}
          icon={ImageIcon}
          onClick={(e) => {
            buttonProps.onClick?.(e);
            useNativeUpload
              ? initNativeImagePicker(e)
              : document.getElementById('image-upload-field').click();
          }}
          aria-label={i18next.t('editor.image.aria_label')}
          tooltip={actionTooltip}
        />
      )}
    </Fragment>
  );
};

/**
 * The V1 Editor uses a more detailed image upload UI, displaying errors and markdown text inline
 *
 * @param {object} props
 * @param {boolean} props.uploadingImage Is an image currently being uploaded
 * @param {boolean} props.useNativeUpload Should iOS native upload functionality be used
 * @param {function} props.handleNativeMessage Callback for iOS native upload message handling
 * @param {function} props.handleInsertionImageUpload Callback to handle image upload
 * @param {string[]} props.insertionImageUrls URLs of successfully uploaded images
 * @param {string} props.uploadErrorMessage Error message to be displayed
 *
 * @returns
 */
const V1EditorImageUpload = ({
  uploadingImage,
  useNativeUpload,
  handleNativeMessage,
  handleInsertionImageUpload,
  insertionImageUrls,
  uploadErrorMessage,
}) => {
  const [showCopiedImageText, setShowCopiedImageText] = useState(false);

  useEffect(() => {
    if (uploadingImage) {
      setShowCopiedImageText(false);
    }
  }, [uploadingImage]);

  const copyText = () => {
    const imageMarkdownInput = document.getElementById(
      'image-markdown-copy-link-input',
    );

    Runtime.copyToClipboard(imageMarkdownInput.value)
      .then(() => {
        setShowCopiedImageText(true);
      })
      .catch((error) => {
        addSnackbarItem({
          message: error,
          addCloseButton: true,
        });
        Honeybadger.notify(error);
      });
  };
  return (
    <div className="flex items-center">
      {uploadingImage && (
        <span class="lh-base pl-3 border-0 py-2 inline-block">
          <Spinner /> {i18next.t('editor.image.uploading')}
        </span>
      )}

      {useNativeUpload ? (
        <NativeIosV1ImageUpload
          uploadingImage={uploadingImage}
          handleNativeMessage={handleNativeMessage}
        />
      ) : uploadingImage ? null : (
        <Fragment>
          <label className="cursor-pointer crayons-btn crayons-btn--ghost">
            <ImageIcon /> {i18next.t('editor.image.text')}
            <input
              type="file"
              id="image-upload-field"
              onChange={handleInsertionImageUpload}
              className="screen-reader-only"
              multiple
              accept="image/*"
              data-max-file-size-mb="25"
            />
          </label>
        </Fragment>
      )}

      {insertionImageUrls.length > 0 && (
        <ClipboardButton
          onCopy={copyText}
          imageUrls={insertionImageUrls}
          showCopyMessage={showCopiedImageText}
        />
      )}

      {uploadErrorMessage ? (
        <span className="color-accent-danger">{uploadErrorMessage}</span>
      ) : null}
    </div>
  );
};

/**
 * Image Uploader feature for editor forms
 *
 * @param {object} props
 * @param {string} props.editorVersion The current editor version being used
 * @param {object} props.buttonProps Any additional props to be added to upload image button (v2 editor only)
 * @param {function} props.onImageUploadStart Callback for when image upload begins
 * @param {function} props.onImageUploadSuccess Callback for when image upload succeeds
 * @param {function} props.onImageUploadError Callback for when image upload fails
 *
 */
export const ImageUploader = ({
  editorVersion = 'v2',
  buttonProps = {},
  onImageUploadStart,
  onImageUploadSuccess,
  onImageUploadError,
}) => {
  const [state, dispatch] = useReducer(imageUploaderReducer, {
    insertionImageUrls: [],
    uploadErrorMessage: null,
    uploadingImage: false,
  });

  const { uploadingImage, uploadErrorMessage, insertionImageUrls } = state;

  function onUploadError(error) {
    onImageUploadError?.();
    dispatch({
      type: 'upload_error',
      payload: { errorMessage: error.message },
    });
  }

  function handleInsertionImageUpload(e, abortSignal) {
    const { files } = e.target;

    if (files.length > 0 && validateFileInputs()) {
      const payload = { image: files };
      dispatch({
        type: 'uploading_image',
      });

      onImageUploadStart?.();
      generateMainImage({
        payload,
        successCb: handleInsertImageUploadSuccess,
        failureCb: onUploadError,
        signal: abortSignal,
      });
    }
  }

  function handleInsertImageUploadSuccess(response) {
    dispatch({
      type: 'upload_image_success',
      payload: { insertionImageUrls: response.links },
    });

    onImageUploadSuccess?.(`![Image description](${response.links})`);

    document.getElementById('upload-success-info').innerText =
      'image upload complete';
  }

  function handleNativeMessage(e) {
    const message = JSON.parse(e.detail);
    if (message.namespace !== 'imageUpload') {
      return;
    }

    switch (message.action) {
      case 'uploading':
        onImageUploadStart?.();
        dispatch({
          type: 'uploading_image',
        });
        break;
      case 'error':
        dispatch({
          type: 'upload_error',
          payload: { errorMessage: message.error },
        });
        break;
      case 'success':
        onImageUploadSuccess?.(`![Image description](${message.link})`);
        dispatch({
          type: 'upload_image_success',
          payload: { insertionImageUrls: [message.link] },
        });
        break;
    }
  }

  // When the component is rendered in an environment that supports a native
  // image picker for image upload we want to add the aria-label attr and the
  // onClick event to the UI button. This event will kick off the native UX.
  // The props are unwrapped (using spread operator) in the button below
  //
  //
  //
  // This namespace is not implemented in the native side. This allows us to
  // deploy our refactor and wait until our iOS app is approved by AppStore
  // review. The old web implementation will be the fallback until then.
  const useNativeUpload = Runtime.isNativeIOS('imageUpload_disabled');

  // Native Bridge messages come through ForemMobile events
  document.addEventListener('ForemMobile', handleNativeMessage);

  return (
    <Fragment>
      <div
        id="upload-success-info"
        aria-live="polite"
        className="screen-reader-only"
      />

      {editorVersion === 'v2' ? (
        <V2EditorImageUpload
          buttonProps={buttonProps}
          uploadingImage={uploadingImage}
          handleInsertionImageUpload={handleInsertionImageUpload}
          useNativeUpload={useNativeUpload}
          handleNativeMessage={handleNativeMessage}
          uploadErrorMessage={uploadErrorMessage}
        />
      ) : (
        <V1EditorImageUpload
          uploadingImage={uploadingImage}
          useNativeUpload={useNativeUpload}
          handleNativeMessage={handleNativeMessage}
          handleInsertionImageUpload={handleInsertionImageUpload}
          insertionImageUrls={insertionImageUrls}
          uploadErrorMessage={uploadErrorMessage}
        />
      )}
    </Fragment>
  );
};

ImageUploader.displayName = 'ImageUploader';
