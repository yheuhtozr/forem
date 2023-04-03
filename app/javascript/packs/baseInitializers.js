import { initializeCommentDate } from './initializers/initializeCommentDate';
import { initializeCommentPreview } from './initializers/initializeCommentPreview';

document.addEventListener('DOMContentLoaded', () => {
  initializeCommentDate();
  initializeCommentPreview();
});
