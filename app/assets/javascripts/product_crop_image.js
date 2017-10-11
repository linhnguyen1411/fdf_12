$(document).on("change", "input#product_crop", function(event){
  var input = $(event.currentTarget);
  var file = input[0].files[0];
  var reader = new FileReader();
  var img_tag = $("#img_product_crop");
  reader.onload = function(e){
    var img = new Image();
    img.src = e.target.result;
    img.onload = function() {
      open_product_crop_modal(img.src, img_tag);
    }
  };
  reader.readAsDataURL(file);
});

function open_product_crop_modal(img, img_tag){
  $.magnificPopup.open({
    items: {
      type: "inline",
      closeBtnInside: true,
      src: "#crop_product_popup"
    },
    callbacks: {
      open: function() {
        $("#crop_product_popup").show();
        $("#crop_product_img").attr("src", img);
        $(".cropper-canvas img, .cropper-view-box img").attr("src", img);
        crop_product_image();
        $("input#submit_crop").click(function(){
          $.magnificPopup.close();
        });
      },
      close: function() {
        var img = new Image();
        img.src = $("#crop_product_img").cropper("getCroppedCanvas").toDataURL("image/png");
        img.onload = function() {
          var img_src = crop_image(img);
          img_tag.attr("src", img_src);
        }
        $("#crop_product_popup").hide();
      }
    }
  });
}

function crop_product_image(){
  var $crop_x = $("input#product_crop_product_x"),
    $crop_y = $("input#product_crop_product_y"),
    $crop_w = $("input#product_crop_product_w"),
    $crop_h = $("input#product_crop_product_h");
  $("#crop_product_img").cropper({
    viewMode: 1,
    aspectRatio: 1,
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
