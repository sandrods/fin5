Rails.application.routes.draw do

  get 'financeiro/diario'
  get 'financeiro/anual'

  resources :registros do
    post :duplicate, on: :member
  end
  resources :transferencias, controller: 'registros/transferencias'

  resources :contas
  resources :categorias
  resources :formas

  get 'dashboard/index'
  root 'dashboard#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
