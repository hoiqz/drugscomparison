Drugscomparison::Application.routes.draw do
  resources :conditioninfographs

  resources :druginfographs

  resources :searches do
    member do
      get 'non_form_search'
    end
  end

 # resources :reviews

  resources :users

  resources :drugs do
    resources :reviews
    member do
      get 'effectiveness_view'
      get 'eou_view'
      get 'satisfactory_view'
      get 'search'
    end
  end
  #match "drugs(/:letter)" => "drugs#index", :as => :drugs_pagination
  match "drugs/index/:letter" => "drugs#index", :as => :drugs_pagination
  match "conditions/index/:letter" => "conditions#index", :as => :conditions_pagination
  resources :conditions do
    member do
      get 'multi_pie_view'
      get 'effectiveness_view'
      get 'eou_view'
      get 'satisfactory_view'
         end
  end


  get 'home', to: "static_pages#home"
  #get "static_pages/review"
  match "static_pages/review", to: "static_pages#review" , via: :get
  get 'static_pages/update_drug_list'
  get 'static_pages/new'
  match "static_pages/create", to: "static_pages#create" , via: [:post, :put]
  #post 'createform', to: 'static_pages#createform'
  #post 'static_pages/create'


scope "(:locale)", locale: /en|cn/ do
  resources :drugs, :conditions, :users, :searches, :static_pages
end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  get '/home/:locale' => 'static_pages#home'
   root :to => 'static_pages#home'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
