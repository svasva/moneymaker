Moneymaker::Application.routes.draw do
  scope 'api' do
    resources :users do
      member { post :send_message }
    end
  end
  namespace :admin do
    resources :users
    resources :greetings
    resources :items
    resources :swfclients do
      member { get :activate }
    end
    root to: 'greetings#index'
  end
  root to: 'home#index'
end
