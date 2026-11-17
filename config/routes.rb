Rails.application.routes.draw do

  # Redirect to localhost from 127.0.0.1 to use same IP address with Vite server
  constraints(host: "127.0.0.1") do
    get "(*path)", to: redirect { |params, req| "#{req.protocol}localhost:#{req.port}/#{params[:path]}" }
  end
  get 'inertia-example', to: 'inertia_example#index'
  #root "maintenance_tickets#index"
  root "home#index"

  resources :equipment do
    get :confirm_destroy, on: :member
  end

  devise_for :users
  resources :maintenance_tickets, path: "issues", only: %i[index new create show]

  namespace :manager do
    resources :maintenance_tickets, only: :index
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  patch "maintenance_tickets/:id/status",
        to: "maintenance_tickets#update_status",
        as: :update_maintenance_ticket_status
end
