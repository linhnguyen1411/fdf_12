$(document).ready(function() {
  var start = null;
  var end = null;

  $(document).on('change','.history-order-manager',function(){
    if($(this).val() == "paid")
      $('.order_reject').fadeOut();
    else
      $('.order_reject').fadeIn();
  });

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

  $('.order-history-start').on('change', function() {
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

  $('.order-history-end').change(function(){
    var value_start = $('.order-history-start').val();
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

  $('.order-history-status').on('click', function() {
    var end_date = $('.order-history-end').val();
    var start_date = $('.order-history-start').val();
    filter_order(start_date, end_date);
  });

  function filter_order(start_date, end_date) {
    var status = $('input[name=history_order_status]:checked').val();
    $.ajax({
      url: $(this).attr('action'),
      type: 'GET',
      data: {
        status: status,
        start_date: start_date,
        end_date: end_date
      }
    });
  };
});
