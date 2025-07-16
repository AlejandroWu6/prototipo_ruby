  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

Rails.application.routes.draw do
  root to: "main#index"

  get "sign_up", to: "registrations#new"
  post "sign_up", to: "registrations#create"

  get "profile", to: "profile#show"

  get "login", to: "session#new"
  post "login", to: "session#create"

  delete "logout", to: "session#destroy"

  get "about", to: "about#index"
end
