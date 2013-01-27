class DropboxController < ApplicationController

  def login
    if dropbox_session && dropbox_session.authorized?
      redirect_to action: :info
    else
      send_to_dropbox
    end
  end

  def send_to_dropbox
    dropbox_session = DropboxSession.new dropbox_config[:app_key], dropbox_config[:app_secret]
    session[:dropbox_session] = dropbox_session.serialize
    redirect_to dropbox_session.get_authorize_url url_for action: 'callback'
  rescue Timeout::Error, DropboxAuthError
    render text: "Unfortunately, we can't connect to Dropbox right now"
  end

  def callback
    dropbox_session.get_access_token
    session[:dropbox_session] = dropbox_session.serialize

    redirect_to home_path
  rescue DropboxAuthError
    render text: "Sorry, we couldn't connect to your Dropbox account."
  end

  def info
    client = DropboxClient.new(dropbox_session, :app_folder) #raise an exception if session not authorized
    render text: client.account_info.to_yaml, content_type: Mime::TEXT
  rescue DropboxAuthError
    render text: 'Not authenticated', content_type: Mime::TEXT
  end

  private

    def dropbox_session
      @dropbox_session ||= DropboxSession.deserialize session[:dropbox_session] if session[:dropbox_session]
    end

    def home_path
      url_for action: 'info'
    end

    def dropbox_config
      Rails.application.config.dropbox
    end

end
