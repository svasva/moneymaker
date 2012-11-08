Moneymaker::Application.routes.draw do
  scope 'api' do
    resources :users do
      member do
        post :send_message
      end
    end
  end
  namespace :admin do
    resources :users
    resources :greetings
    resources :items
  end
  root to: 'home#index'
end
