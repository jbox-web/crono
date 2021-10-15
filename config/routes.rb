# frozen_string_literal: true

if defined?(Rails)
  Crono::Engine.routes.draw do
    resources :jobs
    root 'jobs#index'
  end
end
