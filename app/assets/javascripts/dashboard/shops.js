$(document).ready(function(){
  $('#id_shops_list').find('input.onoffswitch-checkbox').each(function(index, input){
    $(input).on('change', function(){
      if($(input).is(':checked')){
        $.ajax({
          url: '/dashboard/shops/' + $(this).attr('value'),
          type: 'PUT',
          dataType: 'script',
          data:{
            'checked': true
          },
        });
      }
      else {
        $.ajax({
          url: '/dashboard/shops/' + $(this).attr('value'),
          type: 'PUT',
          dataType: 'script',
          data:{
            'checked': false
          },
        });
      }
    })
  })
});
$(document).on('click', '.half-width ul li', (function() {
  $('#products_by_search').val('');
  $('#status_all').prop('checked', true);
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
}));
