class MercadoPagoMessage
  def self.call(response)
    new(response).call
  end

  def initialize(response)
    @response = response
  end

  def call
    case @response
    when "Accredited"
      "Pago acreditado"
    when "pending_contingency"
      "El pago está siendo procesado"
    when "pending_review_manual"
      "El pago está bajo revisión para determinar su aprobación o rechazo"
    when "cc_rejected_bad_filled_date"
      "Fecha de caducidad incorrecta"
    when "cc_rejected_bad_filled_other"
      "Datos de la tarjeta incorrectos"
    when "cc_rejected_bad_filled_security_code"
      "Código de seguridad incorrecto"
    when "cc_rejected_blacklist"
      "La tarjeta está en una lista negra por robo/reclamaciones/fraude"
    when "cc_rejected_call_for_authorize"
      "El medio de pago requiere autorización previa del monto de la operación"
    when "cc_rejected_card_disabled"
      "La tarjeta está inactiva"
    when "cc_rejected_duplicated_payment"
      "Error transacción duplicada"
    when "cc_rejected_high_risk"
      "Rechazo por Prevención de Fraude."
    when "cc_rejected_insufficient_amount"
      "Fondos insuficientes"
    when "cc_rejected_invalid_installments"
      "Número de cuotas no válido."
    when "cc_rejected_max_attempts"
      "Excedió el número máximo de intentos."
    when "Invalid card_number_validation"
      "Datos de la tarjeta incorrectos"
    when "cc_rejected_other_reason"
      "Opps ocurrió un problema al procesar el pago"
    else
      "Opps ocurrió un problema al procesar el pago"
    end
  end
end