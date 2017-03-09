Rails.application.routes.draw do
  devise_for :users
  # get 'welcome/index'
  get 'recipes/index'

  resources :users
  resources :recipes

  root 'recipes#index'
  # root 'devise/sign_in'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
