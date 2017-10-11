# encoding: utf-8

class ShopCoverUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  process :crop_cover
  if Rails.env.production?
    include Cloudinary::CarrierWave
    process tags: ["post_picture"]
  end

  process resize_to_limit: [1280, 860]

  process convert: "png"

  version :standard do
    process resize_to_fill: [400, 300, :north]
  end

  version :thumbnail do
    resize_to_fit 100, 100
  end

  unless Rails.env.production?
    storage :file
  end

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "#{Settings.pictures.upload_dir}/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def default_url *args
    ActionController::Base
      .helpers
      .asset_path([version_name, "default_shop_cover.jpg"].compact.join("_"))
  end

  def crop_cover
    if model.cover_crop_x.present?
      manipulate! do |image|
        x = model.cover_crop_x.to_i
        y = model.cover_crop_y.to_i
        w = model.cover_crop_w.to_i
        h = model.cover_crop_h.to_i
        image.crop "#{w}x#{h}+#{x}+#{y}"
        image
      end
    end
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :resize_to_fit => [50, 50]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_white_list
  #   %w(jpg jpeg gif png)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

end
