$(document).on("change", "input#shop_cover", function(event){
  var input = $(event.currentTarget);
  var file = input[0].files[0];
  var reader = new FileReader();
  var img_tag = $(".img_cover_crop");
  reader.onload = function(e){
    var img = new Image();
    img.src = e.target.result;
    img.onload = function() {
      open_shop_crop_cover_modal(img.src, img_tag);
    }
  };
  reader.readAsDataURL(file);
});

function open_shop_crop_cover_modal(img, img_tag){
  $.magnificPopup.open({
    items: {
      type: "inline",
      closeBtnInside: true,
      src: "#crop_cover_popup"
    },
    callbacks: {
      open: function() {
        $("#crop_cover_popup").show();
        $("#shop_cover_crop").attr("src", img);
        $(".cropper-canvas img, .cropper-view-box img").attr("src", img);
        cropShopcover();
        $("input#submit_crop").click(function(){
          $.magnificPopup.close();
        });
      },
      close: function() {
        var img = new Image();
        img.src = $("#shop_cover_crop").cropper("getCroppedCanvas").toDataURL("image/png");
        img.onload = function() {
          var img_src = crop_image(img);
          img_tag.attr("src", img_src);
        }
        $("#crop_cover_popup").hide();
      }
    }
  });
}

function cropShopcover(){
  var $crop_x = $("input#shop_cover_crop_x"),
    $crop_y = $("input#shop_cover_crop_y"),
    $crop_w = $("input#shop_cover_crop_w"),
    $crop_h = $("input#shop_cover_crop_h");
  $("#shop_cover_crop").cropper({
    viewMode: 1,
    aspectRatio: 21/9,
    background: false,
    zoomable: false,
    getData: true,
    built: function () {
      var croppedCanvas = $(this).cropper("getCroppedCanvas", {
        width: 100, // resize the cropped area
        height: 100
      });

      croppedCanvas.toDataURL(); // Get the 100 * 100 image.
    },
    crop: function(data) {
      $crop_x.val(Math.round(data.x));
      $crop_y.val(Math.round(data.y));
      $crop_h.val(Math.round(data.height));
      $crop_w.val(Math.round(data.width));
    }
  });
}

var crop_image = function(img) {
  var canvas = document.createElement("canvas");
  var ctx = canvas.getContext("2d");
  ctx.drawImage(img, 0, 0);

  var MAX_WIDTH = 1140;
  var MAX_HEIGHT = 785;
  var width = img.width;
  var height = img.height;

  if (width > height) {
    if (width > MAX_WIDTH) {
      height *= MAX_WIDTH / width;
      width = MAX_WIDTH;
    }
  } else {
    if (height > MAX_HEIGHT) {
      width *= MAX_HEIGHT / height;
      height = MAX_HEIGHT;
    }
  }
  canvas.width = width;
  canvas.height = height;
  var ctx = canvas.getContext("2d");
  ctx.drawImage(img, 0, 0, width, height);
  return canvas.toDataURL("image/png");
}
