PuntoTicketExpress::Application.routes.draw do

  # ROOT
  root :to => "home#index"

  # DEVISE
  devise_for :users

  #RESOURCES
  resources :events

  # CUSTOM PAGES
  get '/features', to: 'features#index'
  get '/how_works', to: 'how_works#index'
end
