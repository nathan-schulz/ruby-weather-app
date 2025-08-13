Rails.application.routes.draw do
  # Provides a single endpoint for retrieving weather forecasts.
  # This maps GET /forecasts to the ForecastsController#index action.
  #
  # Example:
  #   GET /forecasts?zipcode=65613
  #     Displays the current weather and high/low temperatures
  resources :forecasts, only: [:index]

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # When visiting http://localhost:3000/, have the request go to
  # ForecastsController's index action to render the weather forecast page
  root "forecasts#index"
end
