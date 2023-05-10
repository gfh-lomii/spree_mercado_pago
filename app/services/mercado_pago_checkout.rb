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

    items = []

    items << {
      id: '000',
      title: 'shipping cost',
      description: 'costo de envío'
      unit_price: (order&.shipments&.to_a&.sum(&:cost) || 0).to_f,
      quantity: 1
    } unless order.pick_up_in_store

    order.line_items.each do |item|
      items << {
        id: item.id.to_s,
        title: item.name,
        description: item.description,
        unit_price: item.price.to_f,
        quantity: item.quantity
      }
    end

    payment_data = {
      transaction_amount: @mercadopago_data.dig(:transaction_amount).to_f,
      token: @mercadopago_data.dig(:token),
      installments: @mercadopago_data.dig(:installments).to_i,
      payment_method_id: @mercadopago_data.dig(:payment_method_id),
      payer: {},
      external_reference: payment.number,
      additional_info: {
        items: items
      },
      metadata: {
        order: order.number
      }
    }

    if @mercadopago_data.dig(:payer, :id).present?
      payment_data[:payer] = {
        id: @mercadopago_data.dig(:payer, :id),
        type: @mercadopago_data.dig(:payer, :type),
      }
    else
      payment_data[:payer] = {
        email: order.user&.email,
        identification: {
          type: @mercadopago_data.dig(:payer, :identification, :type),
          number: @mercadopago_data.dig(:payer, :identification, :number)
        }
      }
    end

    sdk = Mercadopago::SDK.new(payment_method.preferred_access_token)
    payment_response = sdk.payment.create(payment_data)&.dig(:response) || {}
    response_message = payment_response.dig("status_detail") || payment_response.dig("message")

    payment.update(response_code: payment_response.dig("id"))
    case payment_response.dig("status")
    when "approved"
      payment.complete!

      unless @mercadopago_data.dig(:payer, :id).present?
        customers_response = sdk.customer.search(filters: { email: order.user&.email })&.dig(:response)&.dig("results")&.first
        customer_id = customers_response&.dig("id")
        sdk.card.create(customer_id, { token: @mercadopago_data.dig(:token) })
      end
    when "rejected"
      payment.update(cvv_response_message: response_message)
      payment.failure!
    else
      payment.update(cvv_response_message: response_message)
    end

    {
      status: payment_response.dig("status"),
      message: response_message
    }
  end
end
