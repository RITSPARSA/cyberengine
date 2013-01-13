Cyberengine::Application.routes.draw do
  resources :services


  resources :servers


  root to: 'teams#index'
  resources :sessions, only: [:new, :create]
  match 'session' => "sessions#destroy", via: :delete, as: 'session'
  resources :members
  resources :teams

  #scope '/auth', as: 'auth' do
  #  get 'login', to: 'sessions#new', as: 'login'
  #  post 'login', to: 'sessions#create'
  #  get 'logout', to: 'sessions#destroy', as: 'logout'
  #end

  #match '/signin', :to => 'sessions#new'
  #match '/signout', :to => 'sessions#destroy'
  #get "logout" => "sessions#destroy", :as => "logout"
  #get "login" => "sessions#new", :as => "login"
  #get "register" => "users#new", :as => "register"


  #root :to => 'blueteams#index'
  #devise_for :users
  #resources :users

  #resources :blueteams do
  #  resources :servers
  #  resources :server_properties
  #  resources :services
  #  resources :service_properties
  #end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

end
