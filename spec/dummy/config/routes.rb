Rails.application.routes.draw do
  mount Crono::Web, at: '/crono'
end
