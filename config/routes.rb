Rails.application.routes.draw do
  devise_for :users
  get "/up", to: proc { [200, { "Content-Type" => "text/plain" }, ["OK"]] }
  devise_for :admins
  # Admin area lives under /admins (matching the Devise scope). The dashboard is
  # canonically at /admins/dashboard; the namespace root redirects there. Admins
  # land here after signing in via ApplicationController#after_sign_in_path_for.
  namespace :admins do
    get "dashboard", to: "dashboard#index", as: :dashboard
    root to: redirect("/admins/dashboard")
  end
  # ── Customer area (organizers + speakers share one User login) ──────────────
  # One unified dashboard; role resolves per-event, never at login.
  get "dashboard", to: "dashboard#index"
  resource :profile, only: %i[show edit update]   # /profile — reusable speaker profile

  resources :events do
    # Speaker front-of-house: the controller scopes these to current_user.
    resources :submissions, only: %i[index show edit update]

    # Public Call for Papers — shareable, no login required to open the form.
    get  "submit", to: "public_submissions#new",    as: :submit
    post "submit", to: "public_submissions#create"

    # Organizer backstage → /events/:event_id/manage/...
    namespace :manage do
      root "dashboard#index"
      resources :submissions, only: %i[index show update]
    end
  end

  root to: 'welcome#index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
