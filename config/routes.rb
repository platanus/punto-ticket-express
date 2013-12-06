PuntoTicketExpress::Application.routes.draw do
  get "events/:id/promotions", to: 'events#promotions', as: :promotions
  post "events/:id/promotions", to: 'promotions#create'
  get "events/:id/promotions/new", to: 'promotions#new', as: :new_promotion
  get "promotions/:id", to: 'promotions#show', as: :promotion
  put "promotions/:id/enable", to: 'promotions#enable', as: :enable_promotion
  put "promotions/:id/disable", to: 'promotions#disable', as: :disable_promotion

  get "configuration/account"
  put "configuration/update_account"
  get "configuration/producers"
  get "configuration/transactions"

  namespace :puntopagos do
    post "transactions/notification", to: 'transactions#notification'
    get "transactions/notification/:token", to: 'transactions#notification'
    get "transactions/error/:token", to: 'transactions#error', as: :transactions_error
    get "transactions/success/:token", to: 'transactions#success', as: :transactions_success
    get "transactions/new"
    post "transactions/create"
    get "transactions/:id", to: 'transactions#show', as: :transaction
    get "transactions/:id/extra_data", to: 'transactions#nested_resource', as: :transaction_nested_resource
  end

  # ROOT
  root :to => "home#index"

  # DEVISE
  devise_for :users
  ActiveAdmin.routes(self)

  # EVENTS
  get 'me/events', to: 'events#my_index'
  resources :events, only: [:show, :new, :edit, :update, :create, :destroy] do
    member do
      get :participants
      get '/statistics/sold_tickets', to: 'events#sold_tickets', as: :sold_tickets
      get :form, to: 'events#data_to_collect'
      put :publish
    end
  end

  # TICKETS
  resources :tickets, only: [:index, :show] do
    collection do
      get :download
    end
  end

  get "tickets/:id/extra_data", to: 'tickets#nested_resource', as: :ticket_nested_resource

  # PRODUCERS
  resources :producers, except: [:index]

  # CUSTOM PAGES
  get '/features', to: 'features#index'
  get '/how_works', to: 'how_works#index'
end
