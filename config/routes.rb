HenriBox::Application.routes.draw do
  namespace 'dropbox' do
    match 'login'
    match 'callback'
    match 'info'
  end
end
