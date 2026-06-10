# frozen_string_literal: true

module PaddleProducts
  MONTHLY_PRICE_ID = ENV.fetch("PADDLE_MONTHLY_PRICE_ID", "pri_monthly")
  YEARLY_PRICE_ID  = ENV.fetch("PADDLE_YEARLY_PRICE_ID", "pri_yearly")

  MONTHLY_AMOUNT   = 700  # $7.00 in cents
  YEARLY_AMOUNT    = 6700 # $67.00 in cents
end
