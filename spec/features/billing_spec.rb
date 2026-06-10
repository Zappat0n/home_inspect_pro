require "rails_helper"

RSpec.describe "Billing", type: :feature do
  it "redirects to sign in when not authenticated" do
    pg = BillingPage.new
    pg.visit_page

    expect(pg).to have_sign_in_form
  end

  it "shows subscription plans for an authenticated user" do
    country = create(:country)
    user = create(:user, country: country)
    user.set_payment_processor(:paddle_billing)
    user.payment_processor.update_column(:processor_id, "ctm_test123")

    sign_in user
    pg = BillingPage.new
    pg.visit_page

    expect(pg).to have_subscribe_monthly_button
    expect(pg).to have_subscribe_yearly_button
  end
end
