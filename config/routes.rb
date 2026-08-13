Rails.application.routes.draw do
  devise_for :users
  get "/up", to: proc { [200, { "Content-Type" => "text/plain" }, ["OK"]] }
  devise_for :admins
  namespace :admins do
    get "dashboard", to: "dashboard#index", as: :dashboard
    root to: redirect("/admins/dashboard")
  end

  # ── Customer area (organizers + speakers share one User login) ──────────────
  get "dashboard", to: "dashboard#index"
  resource :profile, only: %i[show edit update]

  # ── Speaker portal (global, spans every event the speaker belongs to) ───────
  namespace :portal do
    root "dashboard#index"
    resources :tasks, only: %i[index show] do
      member { post :complete; post :reopen }
    end
    resources :sessions, only: %i[index show] do
      resources :deliverables, only: %i[create] do
        member { post :add_version }
        resources :comments, only: :create, controller: "deliverable_comments"
      end
    end
    resource :profile, only: %i[show edit update], controller: "profile"
    resources :invitations, only: %i[update]     # accept session invitations
  end

  # ── Speaker CRM (org-level, cross-event) ────────────────────────────────────
  namespace :crm do
    root "dashboard#index"
    resources :contacts do
      member { post :enroll; patch :move_stage; post :merge_into; post :add_to_event }
      collection { get :import; post :import; post :bulk_email }
      resources :notes, only: :create, controller: "contact_notes"
    end
    get "pipeline", to: "pipeline#index"
    resources :segments, only: %i[index create destroy]
  end

  resources :events do
    # Speaker front-of-house
    resources :submissions, only: %i[index show edit update]

    # Public Call for Papers — shareable, no login required.
    get  "submit", to: "public_submissions#new", as: :submit
    post "submit", to: "public_submissions#create"
    post "submit/draft", to: "public_submissions#draft", as: :submit_draft

    # ── Public attendee widgets (no login) ──────────────────────────
    get "sessions",  to: "public_widgets#sessions",  as: :public_sessions
    get "speakers",  to: "public_widgets#speakers",  as: :public_speakers
    get "speakers/:speaker_id", to: "public_widgets#speaker", as: :public_speaker
    get "agenda",    to: "public_widgets#agenda",    as: :public_agenda
    get "itinerary", to: "public_widgets#itinerary", as: :public_itinerary
    get "gallery",   to: "public_widgets#gallery",   as: :public_gallery
    get "site",      to: "public_widgets#site",      as: :public_site
    # Embed feeds (JSON/iCal) + rendered embed
    get "embed/:widget", to: "public_widgets#embed", as: :public_embed
    get "feed/:widget",  to: "public_widgets#feed",  as: :public_feed, defaults: { format: "json" }

    # ── Reviewer area ───────────────────────────────────────────────
    namespace :review do
      root "queue#index"
      resources :submissions, only: :show do
        resource :review, only: %i[create update], controller: "reviews"
      end
    end

    # ── Organizer backstage ─────────────────────────────────────────
    namespace :manage do
      root "dashboard#index"
      resource :settings, only: %i[show update], controller: "settings"
      resources :submissions, only: %i[index show new create update edit] do
        member { patch :decide; post :convert }
        collection { patch :bulk_status }
      end
      resources :tracks, except: %i[show]
      resources :rooms, except: %i[show]
      resources :speakers, controller: "event_speakers" do
        collection { get :import; post :import; patch :bulk_status }
      end
      resources :submission_forms do
        resources :form_fields, only: %i[create update destroy]
      end
      resources :review_rounds do
        member { post :add_reviewer; delete :remove_reviewer; post :assign; post :remind; post :ai_evaluate }
        collection { get :results }
      end
      resources :portal_tasks do
        member { patch :toggle }
      end
      resource :agenda, only: %i[show], controller: "agenda" do
        post :place, on: :collection
        post :publish, on: :collection
        post :auto_schedule, on: :collection
        get  :conflicts, on: :collection
      end
      resources :deliverables, only: %i[index show] do
        member { post :approve; post :comment }
        collection { post :bulk_download; post :bulk_remind }
      end
      resources :communications, only: %i[index new create]
      resources :email_templates, except: %i[show]
      get "embeds", to: "embeds#index"
      resources :session_versions, only: %i[] do
        member { post :restore }
      end
    end
  end

  # ── Top-level public shortcuts → the featured (latest published) event ──────
  get "sessions",  to: "public_widgets#featured", defaults: { widget: "sessions" }
  get "speakers",  to: "public_widgets#featured", defaults: { widget: "speakers" }
  get "agenda",    to: "public_widgets#featured", defaults: { widget: "agenda" }
  get "schedule",  to: "public_widgets#featured", defaults: { widget: "agenda" }
  get "itinerary", to: "public_widgets#featured", defaults: { widget: "itinerary" }
  get "gallery",   to: "public_widgets#featured", defaults: { widget: "gallery" }

  root to: "welcome#index"
  get "up" => "rails/health#show", as: :rails_health_check
end
