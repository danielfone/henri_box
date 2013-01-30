class User < DropboxRecord
  attr_reader :name

  def initialize(*args)
    super
    @name = account_info['display_name']
  end

  def galleries
    @galleries ||= app_folder_contents.collect { |hash| Gallery.new @dropbox_session, hash }
  end

  def find_gallery(id)
    galleries.find { |g| g.id == id }
  end

  private

    def account_info
      cache_for_session(:account_info) { dropbox_client.account_info rescue {} }
    end

    def app_folder_contents
      cache_for_session(:app_folder_contents) { dropbox_client.metadata('/')['contents'] rescue [] }
    end

end
