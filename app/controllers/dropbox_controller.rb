class DropboxController < ApplicationController

  def login
    send_to_dropbox
  end

  def send_to_dropbox
    dropbox_session = DropboxSession.new dropbox_config[:app_key], dropbox_config[:app_secret]
    session[:dropbox_session] = dropbox_session.serialize
    redirect_to dropbox_session.get_authorize_url url_for action: 'callback'
  rescue Timeout::Error, DropboxAuthError
    render text: "Unfortunately, we can't connect to Dropbox right now"
  end

  def callback
    dropbox_session = DropboxSession.deserialize session[:dropbox_session]
    dropbox_session.get_access_token
    session[:dropbox_session] = dropbox_session.serialize

    redirect_to home_path
  end

  def info
    dropbox_session = DropboxSession.deserialize session[:dropbox_session]
    client = DropboxClient.new(dropbox_session, :app_folder) #raise an exception if session not authorized
    render text: client.account_info.to_yaml, content_type: Mime::TEXT
  rescue DropboxAuthError
    render text: 'Not authenticated', content_type: Mime::TEXT
  end

  private

    def home_path
      url_for action: 'info'
    end

    def dropbox_config
      Rails.application.config.dropbox
    end

end
