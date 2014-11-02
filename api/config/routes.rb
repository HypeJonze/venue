VenueApp::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # all api routes
  root :to => "static#index"
  post '/contact', :to => 'contact#create'

  namespace :api, :defaults => {:format => :json} do
    namespace :v1 do

      resources :registrations, :only => [:create, :show, :update, :destroy]
      
      # Auth callbacks
      post '/auth/google_oauth2_callback', to: 'auth#google_oauth2_callback'

      post '/signin', :to => 'sessions#create', :as => :signin
      delete '/signout', :to => 'sessions#destroy', :as => :signout

      get '/search/meta', to: 'search#metadata'
      get '/search', to: 'search#results'
      
      resources :categories do
        get 'count', :on => :collection
        get 'admin_index', :on => :collection
      end
      resources :keywords do
        get 'count', :on => :collection
        get 'admin_index', :on => :collection
      end
      resources :neighbourhoods do
        get 'count', :on => :collection
        get 'admin_index', :on => :collection
      end
      resources :venues do
        get 'count', :on => :collection
        get 'admin_index', :on => :collection
      end
      resources :venue_types do
        get 'count', :on => :collection
        get 'admin_index', :on => :collection
      end
    end
  end

end
