Rails.application.routes.draw do
  apipie
  use_doorkeeper

  root to: redirect("/posts")
  resources :posts do
   resources :comments, only: [:create, :new]
  end
  resources :comments, only: [:show, :edit, :update, :destroy]
  # resources :tags
  devise_for :users, controllers: { omniauth_callbacks: 'omniauth_callbacks', registrations: 'registrations' }

  resources :users, only: [:show]
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
