module PhotoHelper
  def thumbnail_tag(photo)
    image_tag gallery_photo_thumbnail_path(@gallery, photo)
  end
end
