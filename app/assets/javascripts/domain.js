$(document).ready(function() {
  var timeouts = [];
  var id, top, left;
  var width = $(window).width();
  var height = $(window).height();
  $(document).on('mousemove', function(e) {
    top = e.clientY;
    left = e.clientX;
  });
  $(document).on('mouseover', '.image_product', function() {
    id = 'item-' + $(this).data('product-id');
    timeouts.push(setTimeout(function(){
      if (top < (height / 2)) {
        if (left < (width / 2)) {
          $('.' + id).css({'top': top + 15, 'left': left + 15})
            .animate({'width': 'show', 'height': 'show'}, 300);
        } else {
          $('.' + id).css({'top': top + 15, 'right': width - left + 15})
            .animate({'width': 'show', 'height': 'show'}, 300);
        }
      } else {
        if (left < (width / 2)){
          $('.' + id).css({'bottom': height - top + 15, 'left': left + 15})
            .animate({'width': 'show', 'height': 'show'}, 300);
        } else {
          $('.' + id).css({'bottom': height - top + 15,
            'right': width - left + 15})
            .animate({'width': 'show', 'height': 'show'}, 300);
        }
      }
    }, 600));
  });
  $(document).on('mouseout', '.image_product', function(){
    clearAllTimeout();
    $.when($('.' + id).animate({'width': 'hide', 'height': 'hide'}, 200))
      .done(function() {
        $('.' + id).css({'top': '', 'bottom': '', 'left': '', 'right': ''});
      });
  });
  function clearAllTimeout() {
    for (var i = 0; i < timeouts.length; i++) {
      clearTimeout(timeouts[i]);
    }
    timeouts = [];
  }
  $('.item-product-shop').hover(function() {
    $(this).find('.toggle_panel').toggle('slide');
  });
  $('.list-domain').hover(function() {
    $(this).find('.domain-item-hidden').slideDown('fast');
  }, function() {
    $(this).find('.domain-item-hidden').slideUp('fast');
  });
  $.validator.addMethod('valid', function(value, element, regex) {
    return this.optional(element) || regex.test(value);
  }, I18n.t('activerecord.errors.models.domain.attributes.name.without'));
  $('#new_domain').validate({
    errorPlacement: function (error, element) {
      error.insertBefore(element);
    },
    rules: {
      'domain[name]': {
        required: true,
        valid: /^[a-zA-ZÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚĂĐĨŨƠàáâãèéêìíòóôõùúăđĩũơƯĂẠẢẤẦẨẪẬẮẰẲẴẶẸẺẼỀỀỂẾưăạảấầẩẫậắằẳẵặẹẻẽềềểếỄỆỈỊỌỎỐỒỔỖỘỚỜỞỠỢỤỦỨỪễệỉịọỏốồổỗộớờởỡợụủứừỬỮỰỲỴÝỶỸửữựỳỵỷỹ]{1}[*ÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚĂĐĨŨƠàáâãèéêìíòóôõùúăđĩũơƯĂẠẢẤẦẨẪẬẮẰẲẴẶẸẺẼỀỀỂẾưăạảấầẩẫậắằẳẵặẹẻẽềềểếỄỆỈỊỌỎỐỒỔỖỘỚỜỞỠỢỤỦỨỪễệỉịọỏốồổỗộớờởỡợụủứừỬỮỰỲỴÝỶỸửữựỳỵỷỹa-zA-Z0-9\-\_\ ]{0,}$/
      }
    },
    messages: {
      'domain[name]': {
        required: I18n.t('activerecord.errors.models.domain.attributes.name.blank')
      }
    }
  });
  $('.btn-edit-domain').click(function() {
    var domain_id = $(this).data('domain-id');
    var edit_domain = document.getElementById('edit_domain_' + domain_id);
    $(edit_domain).validate({
      errorPlacement: function (error, element) {
        error.insertBefore(element);
      },
      rules: {
        'domain[name]': {
          required: true,
          valid: /^[a-zA-ZÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚĂĐĨŨƠàáâãèéêìíòóôõùúăđĩũơƯĂẠẢẤẦẨẪẬẮẰẲẴẶẸẺẼỀỀỂẾưăạảấầẩẫậắằẳẵặẹẻẽềềểếỄỆỈỊỌỎỐỒỔỖỘỚỜỞỠỢỤỦỨỪễệỉịọỏốồổỗộớờởỡợụủứừỬỮỰỲỴÝỶỸửữựỳỵỷỹ]{1}[*ÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚĂĐĨŨƠàáâãèéêìíòóôõùúăđĩũơƯĂẠẢẤẦẨẪẬẮẰẲẴẶẸẺẼỀỀỂẾưăạảấầẩẫậắằẳẵặẹẻẽềềểếỄỆỈỊỌỎỐỒỔỖỘỚỜỞỠỢỤỦỨỪễệỉịọỏốồổỗộớờởỡợụủứừỬỮỰỲỴÝỶỸửữựỳỵỷỹa-zA-Z0-9\-\_\ ]{0,}$/
        }
      },
      messages: {
        'domain[name]': {
          required: I18n.t('activerecord.errors.models.domain.attributes.name.blank')
        }
      }
    });
  });
  $(document).on('click', '[data-destroy="user-domain"]', function(e) {
    e.preventDefault();
    var user_name = $(this).data('user-name');
    var domain_name = $(this).data('domain-name');
    var url = $(this).attr('href');
    swal({
      customClass: 'custom-swal',
      title: I18n.t('common.notifications'),
      text: I18n.t('confirm_delete_user_domain', {user_name: user_name, domain_name: domain_name}),
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
          dataType: "script"
        });
      }
    });
  });
});
