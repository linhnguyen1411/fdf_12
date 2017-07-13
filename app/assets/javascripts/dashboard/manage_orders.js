$(document).ready(function(){

  $('.order-manager-datepicker').datetimepicker({
    timepicker: false,
    format: 'd-m-Y',
    maxDate: $.now()
  });

  $('#filter-order-manager').on('change', function(){
    $.ajax({
      url: $(this).attr('action'),
      type: 'GET',
      data:{
        domain_id: $(this).val(),
        type: $('input[name=status]:checked').val(),
        user_search: $('#order_by_user').val()
      }
    });
  });

  $('.manage-order-status').on('click', function(){
    $.ajax({
      url: $(this).attr('action'),
      type: 'GET',
      data: {
        type: $(this).val(),
        domain_id: $('#filter-order-manager').val(),
        user_search: $('#order_by_user').val()
      }
    });
  });

  $('#order_by_user').on('keyup',function() {
    $.ajax({
      url: $(this).attr('action'),
      type: 'GET',
      data: {
        user_search: $(this).val(),
        domain_id: $('#filter-order-manager').val(),
        type: $('input[name=status]:checked').val()
      }
    });
  });

  function filter_order(start_date, end_date) {
    var shop_id = $('#shop_id').val();
    var type = $('#history-order-manager').val();
    if (type === 'product')
      url = $(this).attr('action');
    else if (type === 'user')
      url = '/dashboard/shops/' + shop_id + '/user_orders'
    else
      url = '/dashboard/shops/' + shop_id + '/group_orders'
    $.ajax({
      url: url,
      type: 'GET',
      data: {
        type: type,
        shop_id: shop_id,
        start_date: start_date,
        end_date: end_date
      }
    });
  };

  var start = null;
  var end = null;

  function compare_current_date(date_s) {
    date_list = date_s.split('-');
    date = new Date(date_list[2], date_list[1] - 1, date_list[0]);
    var currentDate = new Date();
    if (date <= currentDate)
      return true
    else
      return false
  };

  function compare_dates(date_s1, date_s2) {
    date_list1 = date_s1.split('-');
    date_list2 = date_s2.split('-');
    date1 = new Date(date_list1[2], date_list1[1], date_list1[0]);
    date2 = new Date(date_list2[2], date_list2[1], date_list2[0]);
    if (date1 <= date2)
      return true
    else
      return false
  };

  $('#history-order-manager').val('product');

  $('.order-manager-date').val('');

  $('#history-order-manager').on('change', function(){
    var end_date = $('.order-manager-end').val();
    var start_date = $('.order-manager-start').val();
    filter_order(start_date, end_date);
  });

  $('.order-manager-start').change(function(){
    var value_start = $(this).val();
    if(value_start != '' && value_start != start) {
      start = value_start;
      if(compare_current_date(value_start) === false) {
        sweetAlert(I18n.t('api.error'), I18n.t('datepicker.rather_than_current_date'), 'error');
        $(this).val('');
        start = '';
      }
    }
  });

  $('.order-manager-end').change(function(){
    var value_start = $('.order-manager-start').val();
    if(value_start === '') {
      sweetAlert(I18n.t('api.error'), I18n.t('datepicker.date_start_nil'), 'error');
      $(this).val('');
      end = '';
    }
    else {
      var value_end = $(this).val();
      if(value_end != '' && value_end != end) {
        end = value_end;
        if(compare_dates(value_start, value_end) === false) {
          sweetAlert(I18n.t('api.error'),
            I18n.t('datepicker.date_start_rather_than_date_end'), 'error');
          $(this).val('');
          end = '';
        }
        else
          filter_order(value_start, value_end);
      }
    }
  });

  $(document).on('click', '.paid-history-btn', function(e) {
    e.preventDefault();
    var order_id = $(this).data('order-id');
    var shop_id = $(this).data('shop-id');
    $.ajax({
      url: '/dashboard/shops/' + shop_id + '/orders/' + order_id + '/edit',
      type: 'GET',
      dataType: 'json',
      data: {
        checked: true
      },
      success: function(response) {
        if(response.mess === "true") {
          sweetAlert(I18n.t('api.success'), I18n.t('update_success'), 'success');
          $('.check-order-is-paid-'+ order_id)
            .html('<span class="paid-order">'+ I18n.t("paid") + '</span>');
        } else
          sweetAlert(I18n.t('api.error'), I18n.t('update_fails'), 'error');
      },
      error: function(errors) {
        sweetAlert(I18n.t('api.error'), I18n.t('api.error'), 'error');
      }
    });
  });
});
