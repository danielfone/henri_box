HenriBox::Application.routes.draw do
  namespace 'dropbox' do
    match 'login'
    match 'callback'
    match 'info'
  end

  root to: 'application#home'
end
