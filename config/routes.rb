Moneymaker::Application.routes.draw do
  devise_for :admins

  scope 'api' do
    resources :users do
      member { post :send_message }
    end
  end
  namespace :admin do
    resources :users
    resources :greetings
    resources :items
    resources :rooms
    resources :clients
    resources :bank_operations
    resources :atms
    resources :cash_desks
    resources :room_types
    resources :item_types
    resources :settings
    resources :quests
    resources :bank_levels
    resources :quest_characters
    resources :event_handlers
    resources :branches
    resources :branch_levels
    resources :contracts
    resources :swfclients do
      member { get :activate }
    end
    resources :flash_libs do
      member { get :activate }
    end
    root to: 'users#index'
  end
  root to: 'home#index'
end
