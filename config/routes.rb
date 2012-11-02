Moneymaker::Application.routes.draw do
  scope 'api' do
    resources :users do
      member do
        post :send_message
      end
    end
  end
  root to: 'home#index'
end
