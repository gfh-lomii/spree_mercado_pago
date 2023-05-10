module Spree
  module CheckoutControllerDecorator
    def self.prepended(base)
      base.before_action :mercadopago_checkout, only: %i[update]
    end

    def mercadopago_checkout
      if @order.update_from_params(params, permitted_checkout_attributes, request.headers.env)
        @order.temporary_address = !params[:save_user_address]
        if @order.state == 'payment'
          pm_id = params[:order][:payments_attributes].first.dig(:payment_method_id)
          payment_method = Spree::PaymentMethod.find(pm_id)
          if payment_method && payment_method.kind_of?(Spree::PaymentMethod::MercadoPago)
            # pay with mercadopago
            payment_response = MercadoPagoCheckout.call(@order.id, params[:order][:mercadopago])
            @order.reload
            case payment_response.dig(:status)
            when "approved"
              @order.skip_stock_validation = true
              ix = 0
              while !@order.completed? && ix < 5
                @order.next!
                ix += 1
              end

              redirect_to(completion_route) && return
            when "pending", "in_process"
              redirect_to(completion_route) && return
            else
              flash[:error] = MercadoPagoMessage.call(payment_response.dig(:message))
              redirect_to(checkout_state_path(@order.state)) && return
            end
          end
        end
      else
        puts ">>>>> order error message: #{@order.errors.full_messages.join("\n")}"
        render :edit
      end
    end
  end
end

::Spree::CheckoutController.prepend Spree::CheckoutControllerDecorator
