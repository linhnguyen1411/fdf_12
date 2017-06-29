$(document).ready(function(){
  var price = 0;
  var product = null;
  $(document).on('click', '.btn_modal_order_now', function(){
    product = $(this).data('product');
    price = product.price;
    document.getElementById("modal_image").src = product.image.url;
    $('#modal_name').html(product.name);
    $('#modal_price').html(price.toLocaleString() + I18n.t("cart.vnd"));
    var quantity = $('#modal_quantity').html('1');
    $('#modal_total').html(price.toLocaleString() + I18n.t("cart.vnd"));
  });

  $('.modal_quantity_up').click(function(){
    var quantity = parseInt($('#modal_quantity').html());
    if(quantity < 30){
      $('#modal_quantity').html(quantity + 1);
      $('#modal_total').html(((quantity + 1) * price).toLocaleString() + I18n.t("cart.vnd"));
    }
  });

  $('.modal_quantity_down').click(function(){
    var quantity = parseInt($('#modal_quantity').html());
    if(quantity > 1) {
      $('#modal_quantity').html(quantity - 1);
      $('#modal_total').html(((quantity - 1) * price).toLocaleString() + I18n.t("cart.vnd"));
    }
  });

  $('#finish_order_fast').click(function(){
    var quantity = $('#modal_quantity').html();
    var note = $('#modal_note').val();
    $.ajax({
      type: 'POST',
      url : '/order_fasts',
      dataType: 'json',
      context: this,
      data: {
        product_id: product.id,
        note: note,
        quantity: quantity
      },
      success: function(response) {
        if(response.url == '') {
          window.location.reload();
        }
        else {
          window.location = response.url;
        }
      },
      error: function(errors) {
        window.location.reload();
      }
    });
  });
});

$(document).ready(function(){
  $('.update_notes_cart').click(function(){
    $(this).closest('.hide_show').find('.content_note_item_cart').slideToggle(800);
  });

  $('.content_note_cancel').click(function(){
    $(this).closest('.hide_show').find('.content_note_item_cart').slideToggle(800);
  });

  $('.content_note_save').click(function(){
    var note = $(this).closest('.content_note_item_cart').find('.content_note').val();
    var domain_id = $(this).closest('.cart-item-show').data('id');
    var product_id = $(this).closest('a').data('id');
    $.ajax({
      type: 'PUT',
      url : '/carts/1',
      dataType: 'json',
      context: this,
      data: {
        type_notes: "notes",
        product_id: product_id,
        notes: note
      },
      success: function(response) {
        $(this).closest('.content_note_item_cart').hide(800);
      },
      error: function(errors) {
        alert(I18n.t('order_quick.save_fail'));
      }
    });
  });
});

$(document).ready(function(){
  $('#search').keyup(function(){
    $('#search_owner_form').submit();
  });
});

$(document).ready(function() {
  $('input[type=radio][name=filter_order]').change(function() {
    $(this).parent('a').get(0).click();
  });
});

$(document).ready(function(){
  $('.btn_edit_domain').click(function(){
    var id = $(this).parent('td').data('domain-id');
    var name = $(this).parent('td').data('domain-name');
    var status = $(this).parent('td').data('domain-status');
    $('.edit_domain_name').val(name);
    $('.edit_domain_name').parents('form').attr('action', '/domains/' + id + '/edit');
    if(status === 'professed') {
      $('.edit_domain_status').find('option[value="' + status + '"]').attr("selected",true);
      $('.edit_domain_status').find('option[value="secret"]').removeAttr("selected");
    }
    else {
      $('.edit_domain_status').find('option[value="' + status + '"]').attr("selected",true);
      $('.edit_domain_status').find('option[value="professed"]').removeAttr("selected");
    }
  });
});

$(document).ready(function(){
  function compare_current_date(date_s) {
    date_list = date_s.split('/');
    date = new Date(date_list[2], date_list[0], date_list[1]);
    var currentDate = new Date();
    if (date.getDate() <= currentDate.getDate())
      return true
    else
      return false
  };

  function compare_dates(date_s1, date_s2) {
    date_list1 = date_s1.split('/');
    date_list2 = date_s2.split('/');
    date1 = new Date(date_list1[2], date_list1[0], date_list1[1]);
    date2 = new Date(date_list2[2], date_list2[0], date_list2[1]);
    if (date1.getDate() <= date2.getDate())
      return true
    else
      return false
  };

  var start = null;
  var end = null;

  $('.datepicker_ordermanager_start').change(function(){
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

  $('.datepicker_ordermanager_end').change(function(){
    var value_start = $('.datepicker_ordermanager_start').val();
    if(value_start === '') {
      sweetAlert(I18n.t('api.error'), I18n.t('datepicker.date_start_nil'), 'error');
      $(this).val('');
      end = '';
    }
    else {
      var value_end = $(this).val();
      if(value_end != '' && value_end != end) {
        end = value_end;
        if(compare_current_date(value_end) === false) {
          sweetAlert(I18n.t('api.error'), I18n.t('datepicker.rather_than_current_date'), 'error');
          $(this).val('');
          end = '';
        }
        else {
          if(compare_dates(value_start, value_end) === false) {
            sweetAlert(I18n.t('api.error'),
              I18n.t('datepicker.date_start_rather_than_date_end'), 'error');
            $(this).val('');
            end = '';
          }
        }
      }
    }
  });
});

$(document).ready(function(){
  if($(window).width() >= 1200)
    $('.owl-carousel').owlCarousel({
      items: 3,
      loop: true,
      nav:true,
      autoplay: true,
      autoPlaySpeed: 5000,
      autoPlayTimeout: 5000,
      autoplayHoverPause: false
    });
  else
    $('.owl-carousel').owlCarousel({
      items: 2,
      loop: true,
      nav:true,
      autoplay: true,
      autoPlaySpeed: 5000,
      autoPlayTimeout: 5000,
      autoplayHoverPause: false
    });
  $('.owl-prev').addClass('slide-top-shop-prev')
    .html('<i class="material-icons btn-prev-next">keyboard_arrow_left</i>');
  $('.owl-next').addClass('slide-top-shop-next')
    .html('<i class="material-icons btn-prev-next">keyboard_arrow_right</i>')
});

$(document).ready(function(){
  $('.top-shop-slide-item').hover(function(){
    $(this).find('.toggle_panel').slideToggle(500);
  });

  $('.all-shop-slide-item').hover(function(){
    $(this).find('.toggle_panel').slideToggle(500);
  });
});

// open/close shop
$(document).ready(function(){
  $('.btn-open-close-shop').click(function(){
    var btn = $(this);
    var type = btn.data('type');
    if(type === 'close') {
      $.ajax({
        url: '/dashboard/shops/' + $(this).data('id'),
        type: 'PUT',
        dataType: 'json',
        data: {
          'checked': false
        },
        success: function(response) {
          sweetAlert(I18n.t('api.success'), I18n.t('shop_was_closed'), 'success');
          btn.data('type', 'open');
          btn.html('<div class="btn_icon material-icons">lock_open</div><div>' +
            I18n.t("general_info.open_shop_now") + '</div>');
          change_class_after_close_shop(btn);
        },
        error: function(errors) {
          sweetAlert(I18n.t('api.error'), I18n.t('api.error'), 'error');
        }
      });
    }
    else {
      $.ajax({
        url: '/dashboard/shops/' + $(this).data('id'),
        type: 'PUT',
        dataType: 'json',
        data:{
          'checked': true
        },
        success: function(response) {
          sweetAlert(I18n.t('api.success'), I18n.t('shop_was_open'), 'success');
          btn.data('type', 'close');
          btn.html('<div class="btn_icon material-icons">lock_outline</div><div>' +
            I18n.t("general_info.close_shop_now") + '</div>');
          change_class_after_open_shop(btn, response.time)
        },
        error: function(errors) {
          sweetAlert(I18n.t('api.error'), I18n.t('api.error'), 'error');
        }
      });
    }
  });
});

$(document).ready(function(){
  $('#shop_openforever').change(function(){
    $('.time_auto_close_shop').slideToggle(500);
  });
});

// changes picture shop
$(document).ready(function(){
  $('.change_icon').hover(function(){
    $(this).parent('a').find('.change_item').animate({'width': 'show'}, 500);
  }, function() {
    $(this).parent('a').find('.change_item').animate({'width': 'hide'}, 500);
  });

  $('.change_image').click(function(){
    $(this).parent('.change_image_hover').find('input').click();
  });
});

//coutdown time close shop
$(document).ready(function(){
  coutdown_shop_auto_close();
});

function coutdown_shop_auto_close() {
  $('.shop_auto_close').each(function(){
    time = $(this).data('timeclose');
    $(this).countdown(time).on('update.countdown', function(event) {
      $(this).html(event.strftime('%H:%M:%S'));
    }).on('finish.countdown', function(event) {
      change_class_after_close_shop($(this));
      $(this).parents('.manage_shops_item').find('.btn-open-close-shop').data('type', 'open')
        .html('<div class="btn_icon material-icons">lock_open</div><div>' +
        I18n.t("general_info.open_shop_now") + '</div>');
    });
  })
};

function change_class_after_open_shop(object, time) {
  object.parents('.manage_shops_item').removeClass('shop_item_close')
    .addClass('shop_item_open');
  object.parents('.manage_shops_item').find('.shop_closed')
    .addClass('shop_openning').removeClass('shop_closed').html(I18n.t("shop_was_open"));
  object.parents('.manage_shops_item').find('.shop_clock').data('timeclose', time);
  object.parents('.manage_shops_item').find('.shop_clock')
    .addClass('shop_auto_close');
  coutdown_shop_auto_close();
};

function change_class_after_close_shop(object) {
  object.parents('.manage_shops_item').addClass('shop_item_close')
    .removeClass('shop_item_open');
  object.parents('.manage_shops_item').find('.shop_openning')
    .addClass('shop_closed').removeClass('shop_openning').html(I18n.t("shop_was_closed"))
  object.parents('.manage_shops_item').find('.shop_auto_close').countdown('pause');
  object.parents('.manage_shops_item').find('.shop_clock').removeClass('shop_auto_close')
    .html('--:--:--');
};

//manage domain of shop
$(document).ready(function(){
  $('.manage_shops_item').hover(function(){
    $(this).find('.function').animate({'height': 'show'}, 400);
  }, function() {
    $(this).find('.function').animate({'height': 'hide'}, 400);
  });
});

$(document).ready(function(){
  $('.btn_list_orders').click(function(){
    var shop_id = $(this).data('id');
    $.ajax({
      url: '/dashboard/shops/' + shop_id + '/orders',
      type: 'GET',
      dataType: 'json',
      data: {
        check_orders: true
      },
      success: function(response) {
        if(response.orders == 0)
          sweetAlert(I18n.t('api.error'), I18n.t('oder.not_oder'), 'error');
        else
          window.location.href = '/dashboard/shops/' + shop_id + '/orders'
      },
      error: function(errors) {
        sweetAlert(I18n.t('api.error'), I18n.t('api.error'), 'error');
      }
    });
  });
});

//change checkbok paid
$(document).ready(function(){
  $('.is-order-paid').change(function(){
    var order_id = $(this).val();
    var shop_id = $(this).data('shopid');
    var type = $(this).is(':checked');
    $.ajax({
      url: '/dashboard/shops/' + shop_id + '/orders/' + order_id + '/edit',
      type: 'GET',
      dataType: 'json',
      data: {
        checked: type
      },
      success: function(response) {
        if(response.mess === "true")
          sweetAlert(I18n.t('api.success'), I18n.t('update_success'), 'success');
        else
          sweetAlert(I18n.t('api.error'), I18n.t('update_fails'), 'error');
      },
      error: function(errors) {
        sweetAlert(I18n.t('api.error'), I18n.t('api.error'), 'error');
      }
    });
  });
});
