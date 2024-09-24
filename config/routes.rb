Rails.application.routes.draw do
  resources :posts
  resources :subscriptions, only: [:create]
  resources :users, only: [:create] # Add user creation route
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  get '/success', to: 'subscriptions#success'
  get '/cancel', to: 'subscriptions#cancel'
  post 'subscriptions_user/create', to: 'subscriptions_user#create'
  post '/webhooks/stripe', to: 'webhooks#stripe'
  # Defines the root path route ("/")
  # root "posts#index"
end
