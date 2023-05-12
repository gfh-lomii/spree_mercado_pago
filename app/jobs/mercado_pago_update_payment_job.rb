# frozen_string_literal: true

class MercadoPagoUpdatePaymentJob < ApplicationJob
  def perform(x_reference, type)
    Rails.logger.info(">>> on MercadoPagoUpdatePaymentJob: #{x_reference}")
    return if type == "test"

    payment_method = Spree::PaymentMethod.find_by_type("Spree::PaymentMethod::MercadoPago")
    sdk = Mercadopago::SDK.new(payment_method.preferred_access_token)
    payment_response = sdk.payment.get(x_reference)&.dig(:response)
    Rails.logger.info(">>> payment_response: #{payment_response.dig("status")}")
    # GET PAYMENT TO CHECK UPDATES
    payment = Spree::Payment.find_by(response_code: x_reference)
    payment ||= Spree::Payment.find_by!(number: x_reference)

    if !payment.completed?
      response_message = payment_response.dig("status_detail") || payment_response.dig("message")
      case payment_response.dig("status")
      when "approved"
        payment.complete!

        order = payment.order
        order.skip_stock_validation = true
        ix = 0
        while !order.completed? && ix < 5
          order.next!
          ix += 1
        end
      when "rejected"
        payment.update(cvv_response_message: response_message)
        payment.failure!
      else
        payment.update(cvv_response_message: response_message)
      end
    end
  rescue StandardError => e
    request_error(e)
  end

  def request_error(e = nil)
    error_msg = "#{Spree.t('mercado_pago_error')}: #{e.try(:message)}"
    Bugsnag.notify(error_msg)
    error_msg
  end
end
