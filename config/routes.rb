Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  post "/users", to: "users#create"
  post "/auth/login", to: "auth#login"
  post "/auth/logout", to: "auth#logout"

  resources :users, only: [ :create ] do
    resource :stocks do
      post "invest"
      post "update_price"
    end
    resource :wallets, only: [ :show ] do
      post "deposit"
      post "transfer"
      resources :transactions, only: [ :index ]
    end
  end

  resources :teams, only: [ :create ] do
    resource :stocks do
      post "invest"
      post "update_price"
    end
    resource :wallets, only: [ :show ] do
      post "deposit"
      post "transfer"
      resources :transactions, only: [ :index ]
    end
  end

  resources :stocks, only: [ :index ]

  get "/stocks/price_all", to: "latest_stocks#price_all"
end
