class SubscriptionsUserController < ApplicationController
  protect_from_forgery with: :null_session

  def create
    # Create a Stripe Checkout Session for subscription
    response = Stripe::Customer.create({
      name: "Jenny Rosen",
      email: "jennyrosen@example.com",
    })

    render json: { response: response }, status: :ok
  rescue Stripe::StripeError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end
