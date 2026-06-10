Rails.application.routes.draw do
  mount RailsAdmin::Engine => "/admin", as: "rails_admin"

  devise_for :admin_users, controllers: { sessions: "admin/sessions" }
  devise_for :users, controllers: { registrations: "users/registrations" }

  resources :inspections, only: %i[index show new create] do
    member do
      patch :complete
      get :report
    end
    resources :inspection_items, only: [:update] do
      resources :photos, controller: "inspection_photos", only: %i[create destroy]
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  # get "offline" => "rails/pwa#offline", as: :pwa_offline

  # Defines the root path route ("/")
  root "home#index"

  resource :billing, only: [:show], controller: "billing"
end
