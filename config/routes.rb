PuntoTicketExpress::Application.routes.draw do
  get "configuration/account"
  put "configuration/update_account"
  get "configuration/producers"
  get "configuration/transactions"

  namespace :puntopagos do
    post "transactions/notification/:token", to: 'transactions#notification'
    get "transactions/error/:token", to: 'transactions#error', as: :transactions_error
    get "transactions/success/:token", to: 'transactions#success', as: :transactions_success
    get "transactions/new"
    post "transactions/create"
    get "transactions/show/:id", to: 'transactions#show', as: :transaction
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

  resources :tickets, only: [:index, :show] do ||
    collection do
      get :download
    end
  end

  scope :path => '/me' do
    resources :events, only: [:index, :show, :new, :edit] do
      member do
        get :participants
        get :admin, to: 'events#dashboard'
      end

      resources :tickets, only: [:new]
    end
  end

  resources :producers, except: [:index]

  # CUSTOM PAGES
  get '/features', to: 'features#index'
  get '/how_works', to: 'how_works#index'
end



