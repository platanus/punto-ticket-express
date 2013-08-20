PuntoTicketExpress::Application.routes.draw do
  # ROOT
  root :to => "home#index"

  # DEVISE
  devise_for :users
  ActiveAdmin.routes(self)

  #RESOURCES
  resources :events, only: [:show, :update, :destroy] do
    member do
      get :participants
    end
    resources :tickets
  end

  scope :path => '/me' do
    resources :events, only: [:index, :new, :create, :edit] do
      member do
        get :admin, to: 'events#dashboard'
      end
    end
  end

  # CUSTOM PAGES
  get '/features', to: 'features#index'
  get '/how_works', to: 'how_works#index'
end



