PuntoTicketExpress::Application.routes.draw do
  resources :producers


  # ROOT
  root :to => "home#index"

  # DEVISE
  devise_for :users
  ActiveAdmin.routes(self)

  #RESOURCES
  resources :events, only: [:index, :show, :update, :create, :destroy] do
    member do
      get :participants
    end
    resources :tickets, only: [:create]
  end

  resources :tickets, only: [:index, :show]

  scope :path => '/me' do
    resources :events, only: [:index, :show, :new, :edit] do
      member do
        get :participants
        get :admin, to: 'events#dashboard'
      end

      resources :tickets, only: [:new]
    end
  end

  # CUSTOM PAGES
  get '/features', to: 'features#index'
  get '/how_works', to: 'how_works#index'
end



