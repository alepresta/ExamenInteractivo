Rails.application.routes.draw do
  root "examen#index"
  resources :examen, only: [] do
    collection do
      get :preguntas
      get :mostrar_pregunta
      post :responder
      post :siguiente
      get :resultado
    end
  end
end
