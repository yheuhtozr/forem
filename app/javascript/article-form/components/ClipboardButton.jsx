import { h } from 'preact';
import PropTypes from 'prop-types';
import { ButtonNew as Button } from '@crayons';
import CopyIcon from '@images/copy.svg';

function linksToMarkdownForm(imageLinks) {
  return imageLinks
    .map((imageLink) => `![${i18next.t('clipboard.alt_text')}](${imageLink})`)
    .join('\n');
}

export const ClipboardButton = ({
  onCopy,
  imageUrls,
  showCopyMessage = false,
}) => (
  <clipboard-copy
    onClick={onCopy}
    for="image-markdown-copy-link-input"
    aria-live="polite"
    className="flex items-center flex-1"
    aria-controls="image-markdown-copy-link-announcer"
  >
    <input
      data-testid="markdown-copy-link"
      type="text"
      className="crayons-textfield mr-2"
      id="image-markdown-copy-link-input"
      readOnly="true"
      value={linksToMarkdownForm(imageUrls)}
    />
    <Button
      className="spec__image-markdown-copy whitespace-nowrap fw-normal"
      icon={CopyIcon}
      title="Copy markdown for image"
    >
      {i18next.t(showCopyMessage ? 'clipboard.copied' : 'clipboard.copy')}
    </Button>
  </clipboard-copy>
);

ClipboardButton.displayName = 'ClipboardButton';

ClipboardButton.propTypes = {
  onCopy: PropTypes.func.isRequired,
  imageUrls: PropTypes.arrayOf(PropTypes.string).isRequired,
  showCopyMessage: PropTypes.bool.isRequired,
};
