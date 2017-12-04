$(document).ready(function() {
  $.validator.addMethod('shop_valid', function(value, element, regex) {
    return this.optional(element) || regex.test(value);
  }, I18n.t('activerecord.errors.models.shop.attributes.name.without'));
  $('.btn-edit-shop').click(function() {
    var shop_id = $(this).data('shop-id');
    $('#edit-shop-modal').on('show.bs.modal', function() {
      var form_edit_shop = document.getElementById('edit_shop_' + shop_id);
      $(form_edit_shop).validate({
        errorPlacement: function (error, element) {
          error.insertBefore(element);
        },
        rules: {
          'shop[name]': {
            required: true,
            maxlength: 50,
            shop_valid: /^[a-zA-ZÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚĂĐĨŨƠàáâãèéêìíòóôõùúăđĩũơƯĂẠẢẤẦẨẪẬẮẰẲẴẶẸẺẼỀỀỂẾưăạảấầẩẫậắằẳẵặẹẻẽềếềểỄỆỈỊỌỎỐỒỔỖỘỚỜỞỠỢỤỦỨỪễệỉịọỏốồổỗộớờởỡợụủứừỬỮỰỲỴÝỶỸửữựỳỵỷỹ]{1}[*ÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚĂĐĨŨƠàáâãèéêìíòóôõùúăđĩũơƯĂẠẢẤẦẨẪẬẮẰẲẴẶẸẺẼỀỀỂẾưăạảấầẩẫậắằẳẵặẹẻẽềềếểỄỆỈỊỌỎỐỒỔỖỘỚỜỞỠỢỤỦỨỪễệỉịọỏốồổỗộớờởỡợụủứừỬỮỰỲỴÝỶỸửữựỳỵỷỹa-zA-Z0-9\-\_\ ]{0,}$/
          },
          'shop[description]': {
            required: true,
            maxlength: 250
          }
        },
        messages: {
          'shop[name]': {
            required: I18n.t('activerecord.errors.models.shop.attributes.name.blank'),
            maxlength: I18n.t('activerecord.errors.models.shop.attributes.name.too_long')
          },
          'shop[description]': {
            required: I18n.t('activerecord.errors.models.shop.attributes.description.blank'),
            maxlength: I18n.t('activerecord.errors.models.shop.attributes.description.too_long')
          }
        }
      });
    });
  });
  $('#edit-shop-modal').on('hidden.bs.modal', function() {
    $(this).html('');
  });
  $('#new-shop-modal').on('shown.bs.modal', function() {
    $('#new_shop').validate({
      errorPlacement: function (error, element) {
        error.insertBefore(element);
      },
      rules: {
        'shop[name]': {
          required: true,
          maxlength: 50,
          shop_valid: /^[a-zA-ZÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚĂĐĨŨƠàáâãèéêìíòóôõùúăđĩũơƯĂẠẢẤẦẨẪẬẮẰẲẴẶẸẺẼỀỀỂẾưăạảấầẩẫậắằẳẵặẹẻẽềếềểỄỆỈỊỌỎỐỒỔỖỘỚỜỞỠỢỤỦỨỪễệỉịọỏốồổỗộớờởỡợụủứừỬỮỰỲỴÝỶỸửữựỳỵỷỹ]{1}[*ÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚĂĐĨŨƠàáâãèéêìíòóôõùúăđĩũơƯĂẠẢẤẦẨẪẬẮẰẲẴẶẸẺẼỀỀẾỂưăạảấầẩẫậắằẳẵặẹẻẽếềềểỄỆỈỊỌỎỐỒỔỖỘỚỜỞỠỢỤỦỨỪễệỉịọỏốồổỗộớờởỡợụủứừỬỮỰỲỴÝỶỸửữựỳỵỷỹa-zA-Z0-9\-\_\ ]{0,}$/
        },
        'shop[description]': {
          required: true,
          maxlength: 250
        }
      },
      messages: {
        'shop[name]': {
          required: I18n.t('activerecord.errors.models.shop.attributes.name.blank'),
          maxlength: I18n.t('activerecord.errors.models.shop.attributes.name.too_long')
        },
        'shop[description]': {
          required: I18n.t('activerecord.errors.models.shop.attributes.description.blank'),
          maxlength: I18n.t('activerecord.errors.models.shop.attributes.description.too_long')
        }
      }
    });
  });
  $('#new-shop-modal').on('hidden.bs.modal', function() {
    $(this).html('');
  });

  $('#products_by_search').on('keyup',function() {
    search_products();
  });

  $('input[name=search-status]').change(function(){
    search_products();
  });

  search_order_pending();
});

function search_products() {
  var status = $('input[name=search-status]:checked').val();
  var key_word = $('#products_by_search').val();
  var id = $('#products_by_search').data('id');
  var is_list_item = $(".half-width ul li.active").attr('id');
  $.ajax({
    url: '/dashboard/shops/' + id,
    type: 'GET',
    data: {
      key_word: key_word,
      search_satus: status,
      is_list_item: is_list_item
    }
  });
}

function search_order_pending() {
  $('.search-order').keyup(function(){
    var key = $(this).val();
    var domain_id = $(this).data('domain');
    var shop_id = $(this).data('shop')
    $.ajax({
      url: '/domains/' + domain_id + '/shops/' + shop_id + '/edit',
      type: 'GET',
      data: {
        key_search: key,
        search: true
      }
    });
  });
}
