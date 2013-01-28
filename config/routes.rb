HenriBox::Application.routes.draw do
  namespace 'dropbox' do
    match 'login'
    match 'callback'
    match 'sign_out'
  end

  resources :galleries do
    resources :photos
  end

  root to: 'application#home'
end
