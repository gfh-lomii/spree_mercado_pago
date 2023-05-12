module Spree
  class MercadopagoController < Spree::BaseController
    protect_from_forgery except: [:notify]

    # EXAMPLE NOTIFICATION
    # {
    #   "id": 12345,
    #   "live_mode": true,
    #   "type": "payment",
    #   "date_created": "2015-03-25T10:04:58.396-04:00",
    #   "user_id": 44444,
    #   "api_version": "v1",
    #   "action": "payment.created",
    #   "data": {
    #       "id": "999999999"
    #   }
    # }
    def notify
      MercadoPagoUpdatePaymentJob.perform_later(params.dig('data', 'id'), params.dig('type'))
      head :ok
    rescue
      head :unprocessable_entity
    end
  end
end