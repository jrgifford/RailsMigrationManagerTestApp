Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Migration Manager routes
  resources :migrations, only: [:index] do
    member do
      post :run
      post :skip
      post :unskip
      get :show
    end
  end

  # Database-specific migration routes
  get 'migrations/database/:database', to: 'migrations#database', as: :database_migrations
  get 'migrations/database/:database/:id', to: 'migrations#show', as: :database_migration
  post 'migrations/database/:database/:id/run', to: 'migrations#run', as: :run_database_migration
  post 'migrations/database/:database/:id/skip', to: 'migrations#skip', as: :skip_database_migration
  post 'migrations/database/:database/:id/unskip', to: 'migrations#unskip', as: :unskip_database_migration

  # Defines the root path route ("/")
  root "migrations#index"
end
