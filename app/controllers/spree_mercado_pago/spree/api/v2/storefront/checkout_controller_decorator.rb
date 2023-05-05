module SpreeMercadoPago
  module Spree
    module Api
      module V2
        module Storefront
          module CheckoutControllerDecorator
            def self.prepended(base)
              base.before_action :mercadopago_checkout, only: %i[update]
            end

            def mercadopago_checkout
              pm_id = params[:order][:payments_attributes].first.dig(:payment_method_id)
              spree_authorize! :update, spree_current_order, order_token

              result = update_service.call(
                order: spree_current_order,
                params: params,
                # defined in https://github.com/spree/spree/blob/master/core/lib/spree/core/controller_helpers/strong_parameters.rb#L19
                permitted_attributes: permitted_checkout_attributes,
                request_env: request.headers.env
              )

              if spree_current_order.state == 'payment'
                pm_id = params[:order][:payments_attributes].first.dig(:payment_method_id)
                payment_method = ::Spree::PaymentMethod.find(pm_id)
                if payment_method && payment_method.kind_of?(Spree::PaymentMethod::MercadoPago)
                  # pay with mercadopago
                  payment_response = MercadoPagoCheckout.call(spree_current_order.id, params[:order][:mercadopago])
                  spree_current_order.reload
                  if payment_response.dig(:status) == "approved"
                    spree_current_order.skip_stock_validation = true
                    ix = 0
                    while !spree_current_order.completed? && ix < 5
                      spree_current_order.next!
                      ix += 1
                    end

                    render json: { return_url: "/orders/#{spree_current_order.number}" }, status: :ok and return
                  else
                    render_error_payload({ message: payment_response.dig(:message) })
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end

Spree::Api::V2::Storefront::CheckoutController.prepend ::SpreeMercadoPago::Spree::Api::V2::Storefront::CheckoutControllerDecorator