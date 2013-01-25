Cyberengine::Application.routes.draw do
  root to: 'teams#index'

  #namespace :whiteteam do
  #  get 'checks', controller: 'whiteteam'
  #end

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

end
