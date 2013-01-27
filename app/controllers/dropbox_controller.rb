class DropboxController < ApplicationController

  def login
    return redirect_to action: 'send_to_dropbox'
    if session[:dropbox_session]
      return redirect_to home_path
    else
      return redirect_to action: 'send_to_dropbox'
    end
  end

  def send_to_dropbox
    session[:dropbox_session] = dropbox_session.serialize
    redirect_to dropbox_session.get_authorize_url url_for action: 'callback'
  end

  def callback
    dropbox_session.get_access_token
    session[:dropbox_session] = dropbox_session.serialize

    redirect_to home_path
  end

  def info
    client = DropboxClient.new(dropbox_session, :app_folder) #raise an exception if session not authorized
    render text: client.account_info.to_yaml, content_type: Mime::TEXT
  rescue DropboxAuthError
    render text: 'Not authenticated', content_type: Mime::TEXT
  end

  private

    def dropbox_session
      @dropbox_session ||= if session[:dropbox_session]
        DropboxSession.deserialize session[:dropbox_session]
      else
        raise "Dropbox not configured" unless dropbox_config[:app_key] and dropbox_config[:app_secret]
        DropboxSession.new dropbox_config[:app_key], dropbox_config[:app_secret]
      end
    end

    def home_path
      url_for action: 'info'
    end

    def dropbox_config
      Rails.application.config.dropbox
    end

end
