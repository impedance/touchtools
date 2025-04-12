Rails.application.routes.draw do
  devise_for :users

  root 'product_sources#index'

  resources :product_sources do
    resources :product_metrics, only: [:index]
  end

  resources :products do
    collection do
      get 'search'
      post 'find'
    end
  end
  get "up" => "rails/health#show", as: :rails_health_check

end
