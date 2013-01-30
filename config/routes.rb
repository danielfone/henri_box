HenriBox::Application.routes.draw do
  namespace 'auth' do
    match 'login'
    match 'callback'
    match 'sign_out'
  end

  resources :galleries, only: :index do
    resources :photos, only: :index do
      resource :thumbnail, only: :show
    end
  end

  root to: 'application#home'
end
