PuntoTicketExpress::Application.routes.draw do
  # ROOT
  root :to => "home#index"

  # DEVISE
  devise_for :users
  ActiveAdmin.routes(self)

  #RESOURCES
  resources :events do
    member do
      get :participants
    end
  end

  resources :tickets

  # CUSTOM PAGES
  get '/features', to: 'features#index'
  get '/how_works', to: 'how_works#index'
end
