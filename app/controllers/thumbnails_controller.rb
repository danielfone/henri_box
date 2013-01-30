class ThumbnailsController < ApplicationController

  def show
    send_data photo.thumbnail, type: photo.mime_type, disposition: 'inline'
  end

  private

    def photo
      @photo ||= gallery.find_photo params[:photo_id]
    end

    def gallery
      @photo ||= current_user.find_gallery params[:gallery_id]
    end

end
