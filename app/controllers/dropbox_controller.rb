class DropboxController < ApplicationController

  def login
    if dropbox_session && dropbox_session.authorized?
      redirect_to root_path
    else
      send_to_dropbox
    end
  end

  def callback
    dropbox_session.get_access_token
    save_dropbox_session
    redirect_to root_path
  rescue DropboxAuthError
    redirect_to root_path, alert: "Sorry, we couldn't connect to your Dropbox account."
  end

  def sign_out
    session.delete :dropbox_session
    redirect_to root_path
  end

  private

    def dropbox_config
      Rails.application.config.dropbox
    end

    def send_to_dropbox
      setup_session
      save_dropbox_session
      redirect_to dropbox_session.get_authorize_url url_for action: 'callback'
    rescue Timeout::Error, DropboxAuthError, SocketError
      redirect_to root_path, alert: "Sorry, we can't connect to Dropbox right now."
    end

    def setup_session
      @dropbox_session = DropboxSession.new dropbox_config[:app_key], dropbox_config[:app_secret]
    end

    def save_dropbox_session
      session[:dropbox_session] = dropbox_session.serialize
    end

end
