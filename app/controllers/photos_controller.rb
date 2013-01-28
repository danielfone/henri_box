class PhotosController < ApplicationController

  def index
    @photos = dropbox_client.metadata(params[:gallery_id])['contents']
    @photos.each do |photo|
      photo['url'] = dropbox_client.media(photo['path'])['url']
    end
  end

end
