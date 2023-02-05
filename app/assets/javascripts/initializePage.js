/*
  global initializeLocalStorageRender, initializeBodyData,
  initializeAllTagEditButtons, initializeUserFollowButts,
  initializeCommentsPage,
  initializeArticleDate, initializeArticleReactions, initNotifications,
  initializeSettings,
  initializeCommentPreview, initializeRuntimeBanner,
  initializeTimeFixer, initializeDashboardSort,
  initializeArchivedPostFilter, initializeCreditsPage,
  initializeProfileInfoToggle, initializeDrawerSliders,
  initializeProfileBadgesToggle, initializeHeroBannerClose,
  initializeOnboardingTaskCard, initScrolling, nextPage:writable,
  fetching:writable, done:writable, initializePaymentPointers,
  initializeBroadcast, initializeDateHelpers
*/

function callInitializers() {
  initializePaymentPointers();
  initializeCommentsPage();
  initializeArticleDate();
  initializeArticleReactions();
  initNotifications();
  initializeSettings();
  initializeCommentPreview();
  initializeTimeFixer();
  initializeDashboardSort();
  initializeArchivedPostFilter();
  initializeCreditsPage();
  initializeProfileInfoToggle();
  initializeProfileBadgesToggle();
  initializeDrawerSliders();
  initializeHeroBannerClose();
  initializeOnboardingTaskCard();
  initializeDateHelpers();
}

function initializePage() {
  initializeLocalStorageRender();
  initializeBodyData();

  var waitingForDataLoad = setInterval(function wait() {
    if (document.body.getAttribute('data-loaded') === 'true') {
      clearInterval(waitingForDataLoad);
      if (document.body.getAttribute('data-user-status') === 'logged-in') {
        initializeBaseUserData();
        initializeAllTagEditButtons();
      }
      initializeBroadcast();
      initializeReadingListIcons();
      initializeDisplayAdVisibility();
      if (document.getElementById('sidebar-additional')) {
        document.getElementById('sidebar-additional').classList.add('showing');
      }
    }
  }, 1);

  callInitializers();

  function freezeScrolling(event) {
    event.preventDefault();
  }

  nextPage = 0;
  fetching = false;
  done = false;
  setTimeout(function undone() {
    done = false;
  }, 300);
  if (!initScrolling.called) {
    initScrolling();
  }
}
