Moneymaker::Application.routes.draw do
  ActiveAdmin.routes(self)

  devise_for :admin_users, ActiveAdmin::Devise.config

  scope 'api' do
    resources :users do
      member do
        post :send_message
      end
    end
  end
  scope 'admin' do
    resources :users
    resources :greetings
    resources :items
  end
  root to: 'home#index'
end
