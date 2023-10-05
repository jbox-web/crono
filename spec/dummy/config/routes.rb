# frozen_string_literal: true

Rails.application.routes.draw do
  mount Crono::Engine, at: '/crono'
end
