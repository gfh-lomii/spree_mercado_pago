Spree::Core::Engine.add_routes do
  post '/mercadopago/notify', to: 'mercadopago#notify'
end
