Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :users do
    collection do
      post :sign_up, to: :sign_up
      post :sign_in, to: :sign_in
      get :profile, to: :profile
      get :search_user
    end
  end

  resources :folders do
    member do
      post :add_files, to: :add_files
      patch :remove_files, to: :remove_files
      patch :rename_file, to: :rename_file
      post :move_files, to: :move_files
      get :list_files, to: :list_files
    end
  end

  post '/collaborations/add_collaborator', to: 'collaborations#create'
  delete '/collaborations/remove_collaborator', to: 'collaborations#destroy'
end
