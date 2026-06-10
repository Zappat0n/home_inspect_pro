class BillingController < ApplicationController
  def show
    ensure_paddle_customer!

    render(
      locals: {
        customer_id: current_user.payment_processor.processor_id,
        subscribed: current_user.subscribed?,
        monthly_price_id: PaddleProducts::MONTHLY_PRICE_ID,
        yearly_price_id: PaddleProducts::YEARLY_PRICE_ID,
        paddle_environment: paddle_environment,
        paddle_client_token: Pay::PaddleBilling.client_token,
        portal_url: portal_url,
      },
    )
  end

  private

  def ensure_paddle_customer!
    return if current_user.payment_processor&.processor_id.present?

    current_user.set_payment_processor(:paddle_billing)
    current_user.payment_processor.api_record
  rescue Paddle::Errors::ForbiddenError
    flash.now[:alert] = t("billing.show.provider_unavailable")
  end

  def paddle_environment
    @_paddle_environment ||= Pay::PaddleBilling.environment
  end

  def portal_url
    if paddle_environment == "sandbox"
      "https://sandbox-portal.paddle.com"
    else
      "https://portal.paddle.com"
    end
  end
end
