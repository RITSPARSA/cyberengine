require 'resque/server'

Cyberengine::Application.routes.draw do
  root to: 'static#welcome'
  get 'welcome', as: 'welcome', controller: :static
  get 'scoreboard', as: 'scoreboard', controller: :static

  # Teams, Servers, Services
  resources :teams do
    get 'overview', on: :collection
    resources :servers do
      resources :services do
        # Service modals
        resources :checks do
          get 'modal', on: :member
          get 'modal', on: :collection
        end
        resources :users do
          get 'modal', on: :collection
          get 'csv', on: :collection
          post 'csv', on: :collection
        end
        resources :properties do
          get 'modal', on: :collection
        end
      end
      # Server modals
      resources :checks do
        get 'modal', on: :collection
      end
      resources :users do
        get 'modal', on: :collection
      end
      resources :properties do
        get 'modal', on: :collection
      end
    end
  end

  # Authentication
  resources :members
  resources :sessions, only: [:new, :create]
  match 'session' => "sessions#destroy", via: :delete, as: 'session'

  # Redis Server
  mount Resque::Server.new, at: "/redis", as: "redis"
end
