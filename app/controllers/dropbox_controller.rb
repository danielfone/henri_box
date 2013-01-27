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
    dbsession = DropboxSession.new dropbox_config[:app_key], dropbox_config[:app_secret]
    session[:dropbox_session] = dbsession.serialize

    redirect_to dbsession.get_authorize_url url_for action: 'callback'
  end

  def callback
    dbsession = DropboxSession.deserialize session[:dropbox_session]
    dbsession.get_access_token
    session[:dropbox_session] = dbsession.serialize

    redirect_to home_path
  end

  def info
    dbsession = DropboxSession.deserialize(session[:dropbox_session])
    client = DropboxClient.new(dbsession, :app_folder) #raise an exception if session not authorized
    render text: client.account_info.to_yaml, content_type: Mime::TEXT
  end

  private

    def home_path
      url_for action: 'info'
    end

    def dropbox_config
      Rails.application.config.dropbox
    end

end
