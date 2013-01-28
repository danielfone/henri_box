class GalleriesController < ApplicationController

  def index
    @galleries = dropbox_client.metadata('/')['contents']
  end

end
