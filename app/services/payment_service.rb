class PaymentService
  include PayPal::SDK::REST
  include PayPal::SDK::Core::Logging

  def self.perform(params)
    @plan = Plan.new(params)
    @plan.create
    @plan.update({ "path": "/",
                   "value": {
                     "state": "ACTIVE"
                   },
                   "op": "replace" })
    Rails.logger.info @plan.inspect
    @agreement = Agreement.new({
                                 'name' => "Subscribe: #{@plan.name}",
                                 'description' => @plan.description,
                                 'start_date' => 10.minutes.from_now.utc.iso8601,
                                 'payer' => {
                                   'payment_method' => 'paypal'
                                 },
                                 'shipping_address' => {
                                   'line1' => '111 First Street',
                                   'city' => 'Saratoga',
                                   'state' => 'CA',
                                   'postal_code' => '95070',
                                   'country_code' => 'US'
                                 } })

    Rails.logger.info "setting plan id: #{@plan.id}"
    @agreement.plan = Plan.new(id: @plan.id)
    #@agreement.shipping_address = nil
    # Create Payment and return status
    if @agreement.create
      # Redirect the user to given approval url
      @redirect_url = @agreement.links.find { |v| v.method == 'REDIRECT' }.href
      Rails.logger.info "Agreement[#{@agreement.id}]"
      Rails.logger.info "Redirect: #{@redirect_url}"
      @redirect_url
    else
      Rails.logger.error @agreement.error.inspect
    end
  end
end
