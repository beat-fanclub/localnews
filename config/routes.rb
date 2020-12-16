Rails.application.routes.draw do
  resources :posts do
   resources :comments, only: [:new, :create]
  end
  resources :comments, only: [:show, :edit, :update]
  resources :tags
  devise_for :users, controllers: { omniauth_callbacks: 'omniauth_callbacks' }

  devise_scope :user do
    delete 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end
  resources :users, only: [:show]
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
