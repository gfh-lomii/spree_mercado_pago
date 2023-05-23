Spree::Core::Engine.add_routes do
  post '/mercadopago/notify', to: 'mercadopago#notify'
  namespace :api, path: 'api' do
    namespace :v2 do
      namespace :storefront do
        get '/mercadopago/user', to: 'mercadopago#user'
      end
    end
  end
end
