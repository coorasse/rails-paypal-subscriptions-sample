class PaypalSubscription::ResourceFacade
  def self.checkout_url(options)
    response = PayPal::Recurring.new(options).checkout
    raise response.errors.inspect if response.errors.present?
    response.checkout_url
  end

  def self.make_recurring(options)
    response = PayPal::Recurring.new(options).create_recurring_profile
    raise response.errors.inspect if response.errors.present?
    response.profile_id
  end

  def self.cancel(options)
    response = PayPal::Recurring.new(options).cancel
    raise response.errors.inspect if response.errors.present?
    response
  end
end
