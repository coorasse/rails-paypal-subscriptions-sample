class SubscriptionsController < ApplicationController
  def index
    @subscriptions = Subscription.all
  end

  def show
  end

  def create
    @subscription = Subscription.create(subscription_params)
    redirect_to checkout_url
  end

  def make_recurring
    if PaypalSubscription::RecurrenceCreator.create!(
      subscription: subscription,
      paypal_options: paypal_options.merge({
                                             payer_id: params[:PayerID],
                                             token: params[:token]
                                           })
    )
      redirect_to subscription_path(subscription),
                  notice: I18n.t('flashes.subscription.successfully_created')
    end
  end

  def destroy
    PaypalSubscription::ResourceFacade.cancel(paypal_options)

    redirect_to subscription_path(subscription),
                notice: I18n.t('flashes.subscription.cancellation_asked')
  end

  private

  def checkout_url
    puts "return url: #{make_recurring_subscription_url(subscription)}"
    paypal_options[:merchant_preferences]['return_url'] = 'http://www.return.com' #make_recurring_subscription_url(subscription),
    paypal_options[:merchant_preferences]['cancel_url'] = 'http://www.cancel.com' #subscription_url(subscription, aborting_operation: true),
    #paypal_options[:merchant_preferences]['notify_url'] = paypal_ipn_listener_url
    PaymentService.perform(paypal_options)
  end

  def paypal_options
    @paypal_options ||= PaypalSubscription::DefaultOptions.for(subscription)
  end

  def subscription
    @subscription ||= Subscription.find(params[:id])
  end

  helper_method :subscription

  def subscription_params
    params.permit(:plan_id)
  end
end
