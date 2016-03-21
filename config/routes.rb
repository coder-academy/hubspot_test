Rails.application.routes.draw do
  resources :contacts
  resources :enquiries
  root "contacts#index"
end
