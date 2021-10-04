import { h } from 'preact';
import PropTypes from 'prop-types';
import { i18next } from '@utilities/locale';
import { Button } from '@crayons';

export const SettingsForm = ({
  channelDescription,
  handleDescriptionChange,
  channelDiscoverable,
  handleChannelDiscoverableStatus,
  handleChannelDescriptionChanges,
}) => {
  return (
    <div
      data-testid="settings-form"
      className="crayons-card p-4 grid gap-2 mb-4 settings-section"
    >
      <h3>{i18next.t('chat.settings.channel')}</h3>
      <div className="crayons-field">
        <label
          className="crayons-field__label"
          htmlFor="chat_channel_description"
        >
          {i18next.t('chat.settings.description')}
        </label>
        <textarea
          className="crayons-textfield"
          name="description"
          id="chat_channel_description"
          value={channelDescription}
          onChange={handleDescriptionChange}
        />
      </div>
      <div className="crayons-field crayons-field--checkbox">
        <input
          type="checkbox"
          id="c2"
          className="crayons-checkbox"
          checked={channelDiscoverable}
          onChange={handleChannelDiscoverableStatus}
        />
        <label htmlFor="c2" className="crayons-field__label">
          {i18next.t('chat.settings.discoverable')}
        </label>
      </div>
      <div>
        <Button type="submit" onClick={handleChannelDescriptionChanges}>
          {i18next.t('chat.settings.update')}
        </Button>
      </div>
    </div>
  );
};

SettingsForm.propTypes = {
  channelDescription: PropTypes.string.isRequired,
  handleDescriptionChange: PropTypes.func.isRequired,
  handleChannelDiscoverableStatus: PropTypes.func.isRequired,
  handleChannelDescriptionChanges: PropTypes.func.isRequired,
  channelDiscoverable: PropTypes.bool.isRequired,
};
