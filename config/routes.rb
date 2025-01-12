require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  resources :clients do
    namespace :stagegear do
      resources :projector_rentals do
        namespace :stagegear do
          resources :check_ins
        end
      end
    end
  end

  namespace :api, defaults: { format: :json }, format: false do
    namespace :v2 do
      jsonapi_resources :projector_types
      resources :projector_requests do
        collection do
          put 'cancel'
        end
      end
    end
  end
  
  namespace :stagegear do
    resources :projectors
    resources :projector_rentals do
      member do
        patch :confirm
        put :confirm
      end
    end
    resources :check_ins
  end
end
