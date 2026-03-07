Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Debug endpoint for client-side logging
  post "debug_log" => "application#debug_log"

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "recipes#index"

  resources :recipes do
    collection do
      get :import
      post :import
      get :scan
      get :scan_simple
      get :scan_status
      post :scan, action: :process_scan
      post :scan_multiple, action: :process_scan_multiple
      post :crop_image
      post :process_ocr_with_crop
    end
    member do
      delete :purge_image
      delete :purge_document
    end
  end
end
