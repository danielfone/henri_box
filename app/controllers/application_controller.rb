class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :logged_in?
  helper_method :username

private

  def logged_in?
    dropbox_session && dropbox_session.authorized?
  end

  def dropbox_session
    @dropbox_session ||= if session[:dropbox_session]
      DropboxSession.deserialize(session[:dropbox_session])
    end
  end

  def username
    cache_for_session("username") { account_info['display_name'] if account_info } 
  end

  def account_info
    @account_info ||= dropbox_client.account_info if dropbox_client
  end

  def dropbox_client
    @dropbox_client ||= DropboxClient.new(dropbox_session, :app_folder) if dropbox_session
  end

  def cache_for_session(key, &block)
    session_key = dropbox_session.access_token.secret
    full_key = "#{session_key}/#{key}"
    Rails.cache.fetch full_key, &block
  end

end
