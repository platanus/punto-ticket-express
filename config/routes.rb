PuntoTicketExpress::Application.routes.draw do

  # ROOT
  root :to => "home#index"

  # DEVISE
  devise_for :users
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  #RESOURCES
  resources :events

  # CUSTOM PAGES
  get '/features', to: 'features#index'
  get '/how_works', to: 'how_works#index'
end
