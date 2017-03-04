Rails.application.routes.draw do
  post 'bot_actions/process_user_input'

  resources :phones
  resources :televisions
  resources :laptops
  devise_for :users
  root 'home#index'
end
