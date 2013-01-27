class DropboxController < ApplicationController

  def login
    if dropbox_session && dropbox_session.authorized?
      redirect_to action: :info
    else
      send_to_dropbox
    end
  end

  def callback
    dropbox_session.get_access_token
    save_dropbox_session
    redirect_to action: 'info'
  rescue DropboxAuthError
    render text: "Sorry, we couldn't connect to your Dropbox account."
  end

  def info
    render text: dropbox_client.account_info.to_yaml
  rescue DropboxAuthError
    render text: 'Not authenticated'
  end

  private

    def dropbox_session
      @dropbox_session ||= if session[:dropbox_session]
        DropboxSession.deserialize(session[:dropbox_session])
      end
    end

    def dropbox_client
      @dropbox_client ||= DropboxClient.new(dropbox_session, :app_folder)
    end

    def dropbox_config
      Rails.application.config.dropbox
    end

    def send_to_dropbox
      setup_session
      save_dropbox_session
      redirect_to dropbox_session.get_authorize_url url_for action: 'callback'
    rescue Timeout::Error, DropboxAuthError
      render text: "Unfortunately, we can't connect to Dropbox right now"
    end

    def setup_session
      @dropbox_session = DropboxSession.new dropbox_config[:app_key], dropbox_config[:app_secret]
    end

    def save_dropbox_session
      session[:dropbox_session] = dropbox_session.serialize
    end

end
