Rails.application.routes.draw do
  resources :enquiries
  root "enquiries#index"
end
