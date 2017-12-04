$(document).ready(function() {
  $(document).on('click', '.load-more-products a', function(e) {
    e.preventDefault();
    $('.load-more-products a').html(I18n.t('load_more'));
    $.get(this.href, null, null, 'script');
  });
  $(document).on('click', '.load-more-optional-products a', function(e) {
    e.preventDefault();
    $('.load-more-optional-products a').html(I18n.t('load_more'));
    $.get(this.href, null, null, 'script');
  });
});
