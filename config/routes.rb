Moneymaker::Application.routes.draw do
  scope 'api' do
    resources :users
  end
  root to: 'home#index'
end
