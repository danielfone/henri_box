HenriBox::Application.routes.draw do
  namespace 'dropbox' do
    match 'login'
    match 'callback'
    match 'sign_out'
  end

  root to: 'application#home'
end
