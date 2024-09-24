# app/controllers/subscriptions_controller.rb
class SubscriptionsController < ApplicationController
  protect_from_forgery with: :null_session

  def create
    @user = User.find_by(email: subscription_params[:email])

    if @user
      begin
        # Create a Stripe Checkout Session for subscription
        session = Stripe::Checkout::Session.create({
          payment_method_types: ['card'],
          line_items: [{
            price: Rails.application.credentials.dig(:stripe, :sample_price_id),
            quantity: 1
          }],
          mode: 'subscription',
          customer_email: @user.email,
          success_url: "#{request.base_url}/success",
          cancel_url: "#{request.base_url}/cancel"
        })

        # Send back Stripe session URL
        render json: { checkout_url: session.url }, status: :ok
      rescue Stripe::StripeError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end
    else
      render json: { error: 'User not found' }, status: :not_found
    end
  end

  private

  def subscription_params
    params.require(:subscription).permit(:email)
  end
end

