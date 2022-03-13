/* global Honeybadger */

const MAX_RETRIES = 30;
const RETRY_INTERVAL = 250;

function getCsrfToken() {
  var promise = new Promise(function callback(resolve, reject) {
    var i = 0;
    // eslint-disable-next-line consistent-return
    var waitingOnCSRF = setInterval(function waitOnCSRF() {
      var metaTag = document.querySelector("meta[name='csrf-token']");
      i += 1;

      if (metaTag) {
        clearInterval(waitingOnCSRF);
        var authToken = metaTag.getAttribute('content');
        return resolve(authToken);
      }

      if (i === MAX_RETRIES) {
        clearInterval(waitingOnCSRF);
        Honeybadger.notify(
          i18next.t('csrf.notify', {
            user: JSON.stringify(localStorage.current_user),
          }),
        );
        return reject(new Error(i18next.t('csrf.error')));
      }
    }, RETRY_INTERVAL);
  });
  return promise;
}
