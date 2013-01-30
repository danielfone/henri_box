class PhotosController < ApplicationController

  def index
    @photos = gallery.photos
  end

  private

    def gallery
      @gallery ||= current_user.find_gallery params[:gallery_id]
    end

end
