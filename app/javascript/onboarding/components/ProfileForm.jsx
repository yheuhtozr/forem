import { h, Component } from 'preact';
import PropTypes from 'prop-types';

import { userData, updateOnboarding } from '../utilities';
import { i18next } from '../../i18n/l10n';

import { Navigation } from './Navigation';
import { ColorPicker } from './ProfileForm/ColorPicker';
import { TextArea } from './ProfileForm/TextArea';
import { TextInput } from './ProfileForm/TextInput';
import { CheckBox } from './ProfileForm/CheckBox';

import { request } from '@utilities/http';

/* eslint-disable camelcase */
export class ProfileForm extends Component {
  constructor(props) {
    super(props);

    this.handleFieldChange = this.handleFieldChange.bind(this);
    this.handleColorPickerChange = this.handleColorPickerChange.bind(this);
    this.onSubmit = this.onSubmit.bind(this);
    this.user = userData();
    this.state = {
      groups: [],
      formValues: { username: this.user.username },
      canSkip: false,
      last_onboarding_page: 'v2: personal info form',
    };
  }

  componentDidMount() {
    this.getProfileFieldGroups();
    updateOnboarding('v2: personal info form');
  }

  async getProfileFieldGroups() {
    try {
      const response = await request(`/profile_field_groups?onboarding=true`);
      if (response.ok) {
        const data = await response.json();
        this.setState({ groups: data.profile_field_groups });
      } else {
        throw new Error(response.statusText);
      }
    } catch (error) {
      this.setState({ error: true, errorMessage: error.toString() });
    }
  }

  async onSubmit() {
    const { formValues, last_onboarding_page } = this.state;
    const { username, ...newFormValues } = formValues;
    try {
      const response = await request('/onboarding_update', {
        method: 'PATCH',
        body: {
          user: { last_onboarding_page, username },
          profile: { ...newFormValues },
        },
      });
      if (!response.ok) {
        throw response;
      }
      const { next } = this.props;
      next();
    } catch (error) {
      Honeybadger.notify(error.statusText);
      let errorMessage = i18next.t('onboarding.profile.error');
      if (error.status === 422) {
        // parse validation error messages from UsersController#onboarding_update
        const errorData = await error.json();
        errorMessage = errorData.errors;
        this.setState({ error: true, errorMessage });
      } else {
        this.setState({ error: true, errorMessage });
      }
    }
  }

  handleFieldChange(e) {
    const { formValues } = { ...this.state };
    const currentFormState = formValues;
    const { name, value } = e.target;

    currentFormState[name] = value;
    this.setState({
      formValues: currentFormState,
      canSkip: this.formIsEmpty(currentFormState),
    });
  }

  handleColorPickerChange(e) {
    const { formValues } = { ...this.state };
    const currentFormState = formValues;

    const field = e.target;
    const { name, value } = field;

    const sibling = field.nextElementSibling
      ? field.nextElementSibling
      : field.previousElementSibling;
    sibling.value = value;

    currentFormState[name] = value;
    this.setState({
      formValues: currentFormState,
      canSkip: this.formIsEmpty(currentFormState),
    });
  }

  formIsEmpty(currentFormState) {
    // Once we've derived the new form values, check if the form is empty
    // and use that value to set the `canSkip` property on the state.
    Object.values(currentFormState).filter((v) => v.length > 0).length === 0;
  }

  renderAppropriateFieldType(field) {
    switch (field.input_type) {
      case 'check_box':
        return (
          <CheckBox
            key={field.id}
            field={field}
            onFieldChange={this.handleFieldChange}
          />
        );
      case 'color_field':
        return (
          <ColorPicker
            key={field.id}
            field={field}
            onColorChange={this.handleColorPickerChange}
          />
        );
      case 'text_area':
        return (
          <TextArea
            key={field.id}
            field={field}
            onFieldChange={this.handleFieldChange}
          />
        );
      default:
        return (
          <TextInput
            key={field.id}
            field={field}
            onFieldChange={this.handleFieldChange}
          />
        );
    }
  }

  render() {
    const { prev, slidesCount, currentSlideIndex, communityConfig } =
      this.props;
    const { profile_image_90, username, name } = this.user;
    const { canSkip, groups = [], error, errorMessage } = this.state;

    const sections = groups.map((group) => {
      return (
        <div key={group.id} class="onboarding-profile-sub-section">
          <h2>{group.name}</h2>
          {group.description && (
            <div class="color-base-60">{group.description})</div>
          )}
          <div>
            {group.profile_fields.map((field) => {
              return this.renderAppropriateFieldType(field);
            })}
          </div>
        </div>
      );
    });

    return (
      <div
        data-testid="onboarding-profile-form"
        className="onboarding-main crayons-modal"
      >
        <div
          className="crayons-modal__box"
          role="dialog"
          aria-labelledby="title"
          aria-describedby="subtitle"
        >
          <Navigation
            prev={prev}
            next={this.onSubmit}
            canSkip={canSkip}
            slidesCount={slidesCount}
            currentSlideIndex={currentSlideIndex}
          />
          {error && (
            <div role="alert" class="crayons-notice crayons-notice--danger m-2">
              {i18next.t('errors.occurred', { error: errorMessage })}
            </div>
          )}
          <div className="onboarding-content about">
            <header className="onboarding-content-header">
              <h1 id="title" className="title">
                {i18next.t('onboarding.profile.title')}
              </h1>
              <h2
                id="subtitle"
                data-testid="onboarding-profile-subtitle"
                className="subtitle"
              >
                {i18next.t('onboarding.profile.subtitle', {
                  community: communityConfig.communityName,
                })}
              </h2>
            </header>
            <div className="current-user-info">
              <figure className="current-user-avatar-container">
                <img
                  className="current-user-avatar"
                  alt="profile"
                  src={profile_image_90}
                />
              </figure>
              <h3>{name}</h3>
            </div>
            <div className="onboarding-profile-sub-section">
              <TextInput
                field={{
                  attribute_name: 'username',
                  label: 'Username',
                  default_value: username,
                  required: true,
                }}
                onFieldChange={this.handleFieldChange}
              />
            </div>
            {sections}
          </div>
        </div>
      </div>
    );
  }
}

ProfileForm.propTypes = {
  prev: PropTypes.func.isRequired,
  next: PropTypes.func.isRequired,
  slidesCount: PropTypes.number.isRequired,
  currentSlideIndex: PropTypes.func.isRequired,
  communityConfig: PropTypes.shape({
    communityName: PropTypes.string.isRequired,
  }),
};

/* eslint-enable camelcase */
