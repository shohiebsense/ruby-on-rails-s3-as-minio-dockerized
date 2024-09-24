class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def stripe
    event = nil
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    endpoint_secret = Rails.application.credentials.dig(:stripe, :webhook_secret)

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError, Stripe::SignatureVerificationError
      head :bad_request
      return
    end

    # Handle subscription events
    case event['type']
    when 'checkout.session.completed'
      handle_successful_checkout(event)
    when 'invoice.payment_succeeded'
      handle_successful_payment(event)
    when 'customer.subscription.deleted'
      handle_subscription_cancellation(event)
    end

    head :ok
  end

  private

  def handle_successful_checkout(event)
    session = event.data.object
    user = User.find_by(checkout_session_id: session.id)

    # Activate the subscription on your end
    user.update(stripe_subscription_id: session.subscription, status: 'active')
  end

  def handle_successful_payment(event)
    invoice = event.data.object
    user = User.find_by(stripe_subscription_id: invoice.subscription)

    # Handle successful payments (if needed)
    user.update(status: 'active') if user
  end

  def handle_subscription_cancellation(event)
    subscription = event.data.object
    user = User.find_by(stripe_subscription_id: subscription.id)

    # Handle subscription cancellation
    user.update(status: 'canceled') if user
  end
end
