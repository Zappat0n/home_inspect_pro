# frozen_string_literal: true

Pay.setup do |config|
  config.business_name = "HomeInspectPro"
  config.business_address = nil
  config.application_name = "HomeInspectPro"
  config.support_email = "support@homeinspectpro.com"

  config.default_product_name = "default"
  config.default_plan_name = "default"

  config.automount_routes = true
  config.routes_path = "/pay"

  config.enabled_processors = [:paddle_billing]

  config.send_emails = true
  config.parent_mailer = "ApplicationMailer"

  config.emails.payment_action_required = true
  config.emails.payment_failed = true
  config.emails.receipt = true
  config.emails.refund = true
  config.emails.subscription_renewing = ->(_pay_subscription, price) {
    (price&.type == "recurring") && (price.recurring&.interval == "year")
  }
  config.emails.subscription_trial_will_end = true
  config.emails.subscription_trial_ended = true
end
