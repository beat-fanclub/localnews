Rails.application.routes.draw do
  root to: redirect("/posts")
  resources :posts do
   resources :comments, only: [:new, :create]
  end
  resources :comments, only: [:show, :edit, :update]
  # resources :tags
  devise_for :users, controllers: { omniauth_callbacks: 'omniauth_callbacks', registrations: 'registrations' }

  resources :users, only: [:show]
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
