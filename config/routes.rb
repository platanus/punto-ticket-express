PuntoTicketExpress::Application.routes.draw do
  # ROOT
  root :to => "home#index"

  # DEVISE
  devise_for :users
  ActiveAdmin.routes(self)

  # RESOURCES
  resources :events, :only => [:show], shallow: true do
    resources :tickets, :only => [:show, :new, :create]
  end

  # ME NAMESPACE
  namespace :me do
    resources :events
  end

  # CUSTOM PAGES
  get '/features', to: 'features#index'
  get '/how_works', to: 'how_works#index'
end
