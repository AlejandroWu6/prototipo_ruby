  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

Rails.application.routes.draw do
  root to: "main#index"

  get "sign_up", to: "registrations#new"
  post "sign_up", to: "registrations#create"

  get "login", to: "session#new"
  post "login", to: "session#create"
  delete "logout", to: "session#destroy", as: :logout

  get "profile", to: "profile#show"
  post "profile", to: "profile#update"
  delete "profile", to: "profile#destroy", as: :delete_user

  get "password/reset", to: "password_resets#new"
  post "password/reset", to: "password_resets#create"
  get "password/reset/edit/:token", to: "password_resets#edit", as: :edit_password_reset
  patch "password/reset/edit", to: "password_resets#update"

  # --------------------------------------
  # FACTURAS 
  # --------------------------------------
  
  get "invoices/new", to: "invoices#new", as: :new_invoice

  post "invoices/select_format", to: "invoices#select_format", as: :select_invoice_format

  post "invoices", to: "invoices#create"

  get "invoices/:id", to: "invoices#show", as: :invoice

  get "invoices/:id/export/:format_type", to: "invoices#export", as: :export_invoice
  # ---------------------------------------------------------
  get "about", to: "about#index"

end
