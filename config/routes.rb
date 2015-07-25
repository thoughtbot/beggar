Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  resources :github_payloads, only: [:create]
  resource :session, only: [:new, :create, :destroy]
  post "/triggers/slack", to: "triggers/slack#create"

  get "/auth/:provider/callback", to: "sessions#create"
  get "/auth/githubteammember", as: "githubteammember_auth"
  root to: "pull_requests#index"
end
