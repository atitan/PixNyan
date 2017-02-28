Rails.application.routes.draw do
  resources :stream, path: '/', only: :index do
    get ':page', action: :index, on: :collection
  end

  resources :thread, only: :show do
    get ':id/:page', action: :show, on: :collection
  end

  resources :posts, only: [:create]
  delete '/posts', to: 'posts#destroy', as: :post
end
