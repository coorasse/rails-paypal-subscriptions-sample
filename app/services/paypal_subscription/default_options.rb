class PaypalSubscription::DefaultOptions
  def self.for(subscriptable)
    {
      'name': subscriptable.plan.name,
      'description': subscriptable.paypal_description,
      'type': 'FIXED',
      'payment_definitions': [
        {
          'name': 'Regular Payments',
          'type': 'REGULAR',
          'frequency': 'MONTH',
          'frequency_interval': '1',
          'amount': {
            'value': subscriptable.price,
            'currency': 'EUR'
          },
          'cycles': '12',
          'charge_models': [
            {
              'type': 'TAX',
              'amount': {
                'value': subscriptable.price,
                'currency': 'EUR'
              }
            }
          ]
        }
      ],
      merchant_preferences: {
        'auto_bill_amount': 'YES',
        'initial_fail_amount_action': 'CONTINUE',
        'max_fail_attempts': '0'
      }
    }
  end
end
