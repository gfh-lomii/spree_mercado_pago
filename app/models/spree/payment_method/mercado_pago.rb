require 'mercadopago'

module Spree
  class PaymentMethod::MercadoPago < PaymentMethod
    preference :access_token, :string
    preference :public_key, :string

    def provider
      @provider ||= Mercadopago::SDK.new(preferred_access_token || 'accesstoken')
    end

    def payment_profiles_supported?
      false
    end

    def cancel(*)
    end

    def source_required?
      false
    end

    def credit(*)
      self
    end

    def success?
      true
    end

    def authorization
      self
    end

    def payment_method_logo
      ActionController::Base.helpers.asset_path("mercadopago_logo.png")
    end

    def logo
      payment_method_logo
    end
  end
end
