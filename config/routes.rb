Rails.application.routes.draw do
  devise_for :users

  root 'products#search'

  resources :product_sources do
    resources :product_metrics, only: [:index]
  end

  resources :products, only: [:show] do
    collection do
      get 'search', action: :search
      post 'search'
    end
  end
  get "up" => "rails/health#show", as: :rails_health_check
end
