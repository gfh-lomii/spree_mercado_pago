class MercadoPagoCheckout
  def self.call(order_id, mercadopago_data)
    new(order_id, mercadopago_data).call
  end

  def initialize(order_id, mercadopago_data)
    @order_id = order_id
    @mercadopago_data = mercadopago_data || {}
  end

  def call
    order = Spree::Order.find(@order_id)
    payment_method = Spree::PaymentMethod.find_by_type("Spree::PaymentMethod::MercadoPago")
    payment = order.payments.build(payment_method_id: payment_method.id, amount: order.total, state: 'checkout')
    payment.save
    payment.pend!

    payment_data = {
      transaction_amount: @mercadopago_data.dig(:transaction_amount).to_f,
      token: @mercadopago_data.dig(:token),
      installments: @mercadopago_data.dig(:installments).to_i,
      payment_method_id: @mercadopago_data.dig(:payment_method_id),
      payer: {
        email: @mercadopago_data.dig(:payer, :email),
        identification: {
          type: @mercadopago_data.dig(:payer, :identification, :type),
          number: @mercadopago_data.dig(:payer, :identification, :number)
        }
      }
    }

    sdk = Mercadopago::SDK.new(payment_method.preferred_access_token)
    payment_response = sdk.payment.create(payment_data)&.dig(:response) || {}
    puts ">>>>> mercadopago_checkout payment_response: #{payment_response.inspect}"
    if payment_response.dig("status") == "approved"
      payment.update(response_code: payment_response.dig("id"))
      payment.complete!
    else
      payment.update(response_code: payment_response.dig("status_detail") || 'invalid')
      payment.failure!
    end

    {
      status: payment_response.dig("status"),
      message: payment_response.dig("status_detail")
    }
  end
end