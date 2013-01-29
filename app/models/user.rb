class User
  attr_reader :name

  def initialize(dropbox_session)
    raise ArgumentError, "Bad session" unless dropbox_session and dropbox_session.authorized?
    @dropbox_session = dropbox_session
    @name = account_info['display_name']
  end

  def galleries
    @galleries ||= app_folder_contents.collect { |hash| Gallery.new hash }
  end

  private

    def account_info
      cache_for_session(:account_info) { dropbox_client.account_info }
    end

    def dropbox_client
      @dropbox_client ||= DropboxClient.new(@dropbox_session, :app_folder)
    end

    def cache_for_session(key, &block)
      Rails.cache.fetch "#{session_key}/#{key}", &block
    end

    def session_key
      @session_key ||= @dropbox_session.access_token.secret
    end

    def app_folder_contents
      cache_for_session(:app_folder_contents) { dropbox_client.metadata('/')['contents'] rescue [] }
    end

end
