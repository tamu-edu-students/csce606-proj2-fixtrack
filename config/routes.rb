Rails.application.routes.draw do
  # Redirect to localhost from 127.0.0.1 to use same IP address with Vite
  constraints(host: "127.0.0.1") do
    get "(*path)", to: redirect { |params, req|
      "#{req.protocol}localhost:#{req.port}/#{params[:path]}"
    }
  end

  # Authentication
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }

  # Inertia example
  get "inertia-example", to: "inertia_example#index"

  # Root page
  root "home#index"

  # Equipment management
  resources :equipment do
    get :confirm_destroy, on: :member
  end

  # User management
  resources :users, only: %i[new create], path: "manage_users"
  get "/manage_users", to: "users#index", as: :manage_users

  # Maintenance tickets
  resources :maintenance_tickets,
            path: "issues",
            only: %i[index new create show] do
    patch :priority, on: :member,
                     to: "maintenance_tickets#update_priority"

    resources :repair_records,
              only: %i[create edit update destroy]
  end

  # Manager-specific functionality
  namespace :manager do
    resources :maintenance_tickets, only: :index
  end

  # Ticket status updates
  patch "maintenance_tickets/:id/status",
        to: "maintenance_tickets#update_status",
        as: :update_maintenance_ticket_status

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end