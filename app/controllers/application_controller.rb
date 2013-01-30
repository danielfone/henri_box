class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user

  around_filter :rescue_connection_errors

private

  def logged_in?
    dropbox_session && dropbox_session.authorized?
  end

  def dropbox_session
    @dropbox_session ||= if session[:dropbox_session]
      DropboxSession.deserialize(session[:dropbox_session])
    end
  end

  def current_user
    @current_user = User.new dropbox_session if logged_in?
  end

  def rescue_connection_errors
    yield
  rescue Timeout::Error, DropboxAuthError, SocketError
    redirect_to root_path, alert: "Sorry, we can't connect to Dropbox right now."
  end

end
