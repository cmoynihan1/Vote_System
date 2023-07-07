Rails.application.routes.draw do
  resources :campaigns#index
  get '/campaigns/:id', to: 'campaigns#show'
end
