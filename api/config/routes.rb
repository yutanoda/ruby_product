Rails.application.routes.draw do
  namespace 'api' do
    namespace 'v1' do
      resources :users
      get '/summary', to: 'users#summary'
      resources :answers
      get 'log/:user_id', to: 'mypages#log'
      get '/summary', to: 'users#summary'
      get '/books/:user_id', to: 'books#user_books'
      delete '/logout', to: 'sessions#logout'
      post '/login', to: 'sessions#login'
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
