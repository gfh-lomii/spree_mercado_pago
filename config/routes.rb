Spree::Core::Engine.add_routes do
  post '/mercadopago/notify', to: 'mercadopago#notify'
  get '/mercadopago/user', to: 'mercadopago#user'
end
