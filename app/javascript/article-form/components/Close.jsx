import { h } from 'preact';
import { i18next } from '@utilities/locale';
import { ButtonNew as Button } from '@crayons';
import CloseIcon from '@images/x.svg';

export const Close = ({ displayModal = () => {} }) => {
  return (
    <div className="crayons-article-form__close">
      <Button
        icon={CloseIcon}
        onClick={() => displayModal()}
        title={i18next.t('editor.close')}
        aria-label={i18next.t('editor.close')}
      />
    </div>
  );
};

Close.displayName = 'Close';
