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

  # EVENTS
  get 'me/events', to: 'events#my_index'
  resources :events, only: [:show, :new, :edit, :create, :destroy] do
    member do
      get :form, to: 'events#data_to_collect'
    end
  end

  # TICKETS
  resources :tickets, only: [:index, :show] do
    collection do
      get :download
    end
  end

  # PRODUCERS
  resources :producers, except: [:index]

  # CUSTOM PAGES
  get '/features', to: 'features#index'
  get '/how_works', to: 'how_works#index'
end



