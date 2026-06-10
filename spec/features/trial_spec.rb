# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Trial period", type: :feature do
  describe "creating an inspection during trial" do
    it "allows trial user to access new inspection form" do
      country = create(:country, code: "US")
      user = create(:user, country: country)
      create(:inspection_template, country: country, published: true)

      sign_in user

      new_page = Inspections::NewPage.new
      new_page.visit_page
      expect(new_page).to have_heading
      expect(new_page).to have_subscribe_link
    end

    it "blocks expired trial user from creating inspection" do
      country = create(:country, code: "US")
      user = create(:user, country: country, trial_ends_at: 8.days.ago)
      user.set_payment_processor(:paddle_billing)
      user.payment_processor.update_column(:processor_id, "ctm_test123")

      sign_in user

      visit new_inspection_path

      billing_page = BillingPage.new
      expect(billing_page).to have_heading
      expect(billing_page).to have_trial_expired_alert
    end
  end
end
