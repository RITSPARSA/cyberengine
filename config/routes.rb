Cyberengine::Application.routes.draw do
  root to: 'teams#index'

  # Teams, Servers, Services
  resources :teams do
    get 'overview', on: :collection
    #resources :checks, only: [:index]
    resources :servers do
      resources :services do
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
    end
  end

  # Authentication
  resources :members
  resources :sessions, only: [:new, :create]
  match 'session' => "sessions#destroy", via: :delete, as: 'session'

end
