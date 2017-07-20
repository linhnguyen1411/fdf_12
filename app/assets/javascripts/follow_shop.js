$(document).ready(function() {
  $('body').on('click', '.follow-shop', function() {
    var self = $(this);
    var shop_id = $('#shop_id').val();
    $.ajax({
      url: '/follow_shops/',
      data: {shop_id: shop_id},
      type: 'POST',
      success: function(data) {
        if(data.status === 200) {
          $.growl.notice({title: '', message: data.flash});
          self.removeClass('follow-shop btn-warning')
            .addClass('unfollow-shop btn-danger');
          self.text(I18n.t('unfollow'));
           $('.shop-followers-count').text(data.follow_count);
        }
        else {
          $.growl.error({message: data.flash});
        }
      },
      error: function(error) {
        $.growl.error({message: error});
      }
    });
    return false;
  });
 
  $('body').on('click', '.unfollow-shop', function() {
    var self = $(this);
    var shop_id = $('#shop_id').val();
    $.ajax({
      url: '/follow_shops/' + shop_id,
      data: {shop_id: shop_id},
      type: 'DELETE',
      success: function(data) {
        if(data.status === 200) {
          $.growl.warning({title: '', message: data.flash});
          self.removeClass('unfollow-shop btn-danger')
            .addClass('follow-shop btn-warning');
          self.text(I18n.t('follow'));
          $('.shop-followers-count').text(data.follow_count);
        }
        else {
          $.growl.error({message: data.flash});
        }
      },
      error: function(error) {
        $.growl.error({message: error});
      }
    });
    return false;
  });
});
