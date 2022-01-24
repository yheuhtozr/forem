import { h } from 'preact';
import { useEffect, useState } from 'preact/hooks';
import PropTypes from 'prop-types';
import { TagAutocompleteOption } from './TagAutocompleteOption';
import { TagAutocompleteSelection } from './TagAutocompleteSelection';
import { MultiSelectAutocomplete } from '@crayons';
import { fetchSearch } from '@utilities/search';

// chain of full tag pattern syntax with permissive apostrophe cf. /app/models/tag.rb
export const DEFAULT_TAG_FORMAT = "(?:(?:['\\p{XIDS}\\p{Nd}\\p{No}](?:['\\p{XIDC}\\p{No}\u00B7\u0F0B\u05F3\u05F4\u200C\u200D]*['\\p{XIDC}\\p{No}\u0F0B])?)?(?:, |$))+";

  return (
    <MultiSelectAutocomplete
      defaultValue={defaultSelections}
      fetchSuggestions={fetchSuggestions}
      staticSuggestions={topTags}
      staticSuggestionsHeading={
        <h2 className="crayons-article-form__top-tags-heading">Top tags</h2>
      }
      labelText="Add up to 4 tags"
      showLabel={false}
      placeholder="Add up to 4 tags..."
      border={false}
      maxSelections={4}
      SuggestionTemplate={TagAutocompleteOption}
      SelectionTemplate={TagAutocompleteSelection}
      onSelectionsChanged={syncSelections}
      onFocus={switchHelpContext}
      inputId="tag-input"
    />
  );
};

TagsField.propTypes = {
  onInput: PropTypes.func.isRequired,
  defaultValue: PropTypes.string,
  switchHelpContext: PropTypes.func,
};
