PuntoTicketExpress::Application.routes.draw do
  namespace :puntopagos do
    post "/transactions/notification"
    get "transactions/error/:token", to: 'transactions#error', as: :transactions_error
    get "transactions/success/:token", to: 'transactions#success', as: :transactions_success
    get "transactions/new"
    post "transactions/create"
    get "transactions/show", to: 'transactions#show', as: :transaction
  end

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

  resources :producers

  # CUSTOM PAGES
  get '/features', to: 'features#index'
  get '/how_works', to: 'how_works#index'
end



