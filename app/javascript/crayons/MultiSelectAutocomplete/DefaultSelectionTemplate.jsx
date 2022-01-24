import { h } from 'preact';
import { Icon, ButtonNew as Button } from '@crayons';
import { Close } from '@images/x.svg';
import { i18next } from '@utilities/locale';

export const DefaultSelectionTemplate = ({ name, onEdit, onDeselect }) => (
  <div role="group" aria-label={name} className="flex mr-1 mb-1 w-max">
    <Button
      variant="secondary"
      className="c-autocomplete--multi__selected p-1 cursor-text"
      aria-label={i18next.t('crayons.tagAutocomplete.aria_edit', {
        item: name,
      })}
      onClick={onEdit}
    >
      {name}
    </Button>
    <Button
      variant="secondary"
      className="c-autocomplete--multi__selected p-1"
      aria-label={i18next.t('crayons.tagAutocomplete.aria_remove', {
        item: name,
      })}
      onClick={onDeselect}
    >
      <Icon src={Close} />
    </Button>
  </div>
);
