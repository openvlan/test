Rails.application.routes.draw do
  delete :cleanup, to: 'cleanup#clean_database' unless Rails.env.production?

  get '_healthcheck', action: :health, controller: :health
  get '_sentry', action: :sentry, controller: :health

  get 'ping_async', action: :ping_async, controller: :health

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  scope module: :v1, constraints: ApiConstraint.new(version: 1, default: true) do
    resources :shippers, only: [] do
      get :last_location
    end

    resources :trips, only: [ :create, :show, :update ]
  end
# | - End of Version 1
# ╰─ End of Private Accesible URL's / Path's

  namespace :v1 do
    resources :delivery_costs, only: [] do
      collection do
        get :calculate
      end
    end

    resources :orders, only: %i[] do
      collection do
        get :trip_planner
        delete :destroy_by_marketplace_order
      end
    end

    resources :drivers, only: %i[index show update create] do
      collection do
        post :table
        post :onboarding
        get :me
        put :me, action: :update_me
        get 'me/default_payment_method', action: :show_my_default_payment_method
        post 'me/default_payment_method', action: :create_my_default_payment_method
        put 'me/default_payment_method', action: :update_my_default_payment_method
        get ':id/audits', action: :audits
        get ':id/show_by_user_id', action: :show_by_user_id
        post ':id/audits', action: :add_audit
        post ':id/status', action: :change_status
      end
    end

    resources :direct_uploads, only: [:create]

    resources :trips, only: %i[create show update] do
      collection do
        post :list
      end

      member do
        post :cancel
        post :confirm_driver
        post :start
        post :complete
      end
    end

    scope module: 'drivers', path: 'drivers-app' do
      resources :trips, only: %i[show index] do
        collection do
          get :history, action: :trip_history
          post :pickup
          post :deliver
        end
        member do
          post :take
          post :start
          post :milestone
          post :cancel
          post :complete
        end
      end

      resources :shippers, only: [] do
        collection do
          post :set_current_location
          get :has_on_going_trips
        end
      end
    end
  end

  resources :trips, only: [] do
    resources :trip_payments, path: :payments, only: [:create]
  end

  resources :trip_step_photos, only: [:index, :create, :destroy]

  resources :trip_payments, only: [:index] do
    member do
      put :mark_as_paid
    end
  end

  namespace :resources do
    resources :orders, only: %i[create show]
  end

  namespace :services do
    resources :shippers, only: [:create] do
      collection do
        get :statuses_by_user_ids
      end
    end
  end
end
