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

Deface::Override.new(
  virtual_path: 'spree/checkout/_checkout_new_version',
  name: 'remove_old_submit_button',
  remove: 'erb[loud]:contains("button_tag")',
  closing_selector: "erb[silent]:contains('end')",
  original: %q(
    <%= button_tag type: 'submit', class: "btn primary btn-sm p-2 mt-2 btn-block", data: { action: 'click->checkout#onSubmit' } do %>
      <div class="d-flex justify-content-between px-3">
        <span><%= Spree.t(:pay).capitalize %></span>
        <span><%= @order.display_total.to_html %></span>
      </div>
    <% end %>
  )
)

Deface::Override.new(
  virtual_path: 'spree/checkout/_checkout_new_version',
  name: 'mercado_pago_button',
  insert_bottom: 'div#checkout-details',
  text: %q(
    <!-- BUTTON FOR MERCADO PAGO FORM -->
    <%= button_tag type: 'button', id: "mercado-pago-button", class: "btn primary btn-sm p-2 mt-2 btn-block #{'d-none' unless default_method.kind_of?(Spree::PaymentMethod::MercadoPago)}" do %>
      <div class="d-flex justify-content-between px-3">
        <span><%= Spree.t(:pay).capitalize %></span>
        <span><%= @order.display_total.to_html %></span>
      </div>
    <% end %>
  )
)
