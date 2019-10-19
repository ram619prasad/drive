Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :users do
    collection do
      post :sign_up, to: :sign_up
      post :sign_in, to: :sign_in
    end
  end
end
