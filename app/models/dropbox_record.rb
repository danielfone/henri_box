class DropboxRecord

  def initialize(dropbox_session)
    raise ArgumentError, "Bad session" unless dropbox_session and dropbox_session.authorized?
    @dropbox_session = dropbox_session
  end

  protected

    def dropbox_client
      @dropbox_client ||= DropboxClient.new(@dropbox_session, :app_folder)
    end

    def cache_for_session(key, &block)
      Rails.cache.fetch [session_key, key], &block
    end

  private

    def session_key
      @session_key ||= @dropbox_session.access_token.secret
    end

end