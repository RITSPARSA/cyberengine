Cyberengine::Application.routes.draw do
  root to: 'teams#index'

  resources :teams do
    resources :servers
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
    get 'overview', on: :collection
  end

  # Authentication
  resources :members
  resources :sessions, only: [:new, :create]
  match 'session' => "sessions#destroy", via: :delete, as: 'session'

end
