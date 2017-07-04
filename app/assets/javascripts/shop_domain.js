$(document).ready(function() {
  $(document).on('click', '[data-destroy="shop-domain"]', function(e) {
    e.preventDefault();
    var shop_name = $(this).data('shop-name');
    var domain_name = $(this).data('domain-name');
    var url = $(this).attr('href');
    if ($(this).data('leave-domain') == 0) {
      var text_notification = I18n.t('confirm_leave_shop_domain',
        {shop_name: shop_name, domain_name: domain_name});
    } else {
      var text_notification = I18n.t('confirm_cancel_request_shop',
        {shop_name: shop_name, domain_name: domain_name});
    }
    swal({
      customClass: 'custom-swal',
      title: I18n.t('common.notifications'),
      text: text_notification,
      showCancelButton: true,
      confirmButtonColor: '#ff5722',
      confirmButtonText: I18n.t('submit'),
      cancelButtonText: I18n.t('cancel'),
      closeOnCancel: true
    }, function(confirmed) {
      if(confirmed) {
        $.ajax({
          url: url,
          type: "delete",
          data: {delete_request: true},
          dataType: "script"
        });
      }
    });
  });

  $('.modal-request-shop-domain').on('shown.bs.modal', function() {
    var shop_id = $(this).data('shop-id');
    var data = {list_request_shop_domain: true, shop_id: shop_id}
    $.get('/shop_domains', data, null, 'script');
  });
});
