import { h } from 'preact';
import PropTypes from 'prop-types';
import { Tags } from '../../shared/components/tags';

// chain of full tag pattern syntax with permissive apostrophe cf. /app/models/tag.rb
export const DEFAULT_TAG_FORMAT = "(?:(?:['\\p{XIDS}\\p{Nd}\\p{No}](?:['\\p{XIDC}\\p{No}\u00B7\u0F0B\u05F3\u05F4\u200C\u200D]*['\\p{XIDC}\\p{No}\u0F0B])?)?(?:, |$))+";

export const TagsField = ({
  defaultValue,
  onInput,
  switchHelpContext,
  tagFormat = DEFAULT_TAG_FORMAT,
}) => {
  return (
    <div className="crayons-article-form__tagsfield">
      <Tags
        defaultValue={defaultValue}
        maxTags={4}
        onInput={onInput}
        onFocus={switchHelpContext}
        classPrefix="crayons-article-form"
        fieldClassName="crayons-textfield crayons-textfield--ghost ff-monospace"
        pattern={tagFormat}
      />
    </div>
  );
};

TagsField.propTypes = {
  onInput: PropTypes.func.isRequired,
  defaultValue: PropTypes.string.isRequired,
  switchHelpContext: PropTypes.func.isRequired,
};

TagsField.displayName = 'TagsField';
