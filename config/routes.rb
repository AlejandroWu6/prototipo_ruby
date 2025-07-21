  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

Rails.application.routes.draw do
  root to: "main#index"

  get "sign_up", to: "registrations#new"
  post "sign_up", to: "registrations#create"

  get "profile", to: "profile#show"
  post "profile", to: "profile#update"

  get "login", to: "session#new"
  post "login", to: "session#create"

  get "password/reset", to: "password_resets#new"
  post "password/reset", to: "password_resets#create"
  get "password/reset/edit/:token", to: "password_resets#edit", as: :edit_password_reset
  patch "password/reset/edit", to: "password_resets#update"

  delete "logout", to: "session#destroy"

  get "about", to: "about#index"
end
