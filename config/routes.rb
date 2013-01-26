HenriBox::Application.routes.draw do
  match '/login', to: 'dropbox#login'
  match '/dropbox/send_to_dropbox', to: 'dropbox#send_to_dropbox'
  match '/dropbox/callback', to: 'dropbox#callback'
  match '/dropbox/info', to: 'dropbox#info'
end
