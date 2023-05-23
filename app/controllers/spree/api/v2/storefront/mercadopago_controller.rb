class Spree::Api::V2::Storefront::MercadopagoController < ::Spree::Api::V2::ResourceController
  before_action :require_spree_current_user

  def user
    render json: GetMercadoPagoPayer.call(spree_current_user&.id), status: :ok
  end
end