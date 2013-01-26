require 'dropbox_sdk'
Rails.application.config.dropbox = {
  app_key:      ENV['DROPBOX_APP_KEY'],
  app_secret:   ENV['DROPBOX_APP_SECRET'],
}