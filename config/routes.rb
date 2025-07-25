  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

Rails.application.routes.draw do
  root to: "main#index"

  get "sign_up", to: "registrations#new"
  post "sign_up", to: "registrations#create"

  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout

  get "profile", to: "profile#show"
  patch "profile", to: "profile#update"         
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

  post "invoices/form", to: "invoices#select_format", as: :select_invoice_format
  get "invoices/form", to: "invoices#new_form", as: :invoice_form

  post "invoices", to: "invoices#create"

  get "invoices/:id", to: "invoices#show", as: :invoice

  get "invoices/:id/export/:format_type", to: "invoices#export", as: :export_invoice
  # ---------------------------------------------------------
  get "about", to: "about#index"

end
