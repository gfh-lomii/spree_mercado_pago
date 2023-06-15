Deface::Override.new(
  virtual_path: 'spree/checkout/_payment_methods',
  name: 'mercado_pago_payment_method',
  insert_top: '[data-hook="payment_methods_list"]',
  text: "<%= render 'spree/checkout/sources/mercado_pago' %>"
)

Deface::Override.new(
  virtual_path: 'spree/checkout/_payment_methods',
  name: 'mercado_pago_default_payment_method',
  insert_after: '[data-target="checkout.kushki"]',
  text: %{
    <div id='checkout-mercado-pago' class="mt-3 <%= 'd-none' unless default_method.kind_of?(Spree::PaymentMethod::MercadoPago) %>">
      <%= render partial: "spree/checkout/payment/mercado_pago" %>
    </div>
  }
)