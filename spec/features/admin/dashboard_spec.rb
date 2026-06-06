# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin Dashboard", type: :feature do
  describe "viewing the dashboard" do
    it "displays the dashboard, lists all managed models, and navigates to a model list page" do
      admin_user = create(:admin_user)

      sign_in_page = AdminSignInPage.new
      sign_in_page.visit_page
      sign_in_page.fill_in_with(admin_user.email, "password123")
      sign_in_page.submit

      expect(sign_in_page).to have_signed_in_message

      pg = AdminDashboardPage.new
      pg.visit_page

      expect(pg).to have_heading
      expect(pg).to have_model("Admin users")
      expect(pg).to have_model("Users")
      expect(pg).to have_model("Countries")
      expect(pg).to have_model("Inspection templates")
      expect(pg).to have_model("Checklist items")

      pg.click_model("Countries")

      expect(pg).to have_list_heading_for("Countries")
    end

    it "shows record counts for each model" do
      admin_user = create(:admin_user)
      country = create(:country)
      create(:user, country: country)
      inspection_template = create(:inspection_template, country: country)
      create(:checklist_item, inspection_template: inspection_template)

      sign_in_page = AdminSignInPage.new
      sign_in_page.visit_page
      sign_in_page.fill_in_with(admin_user.email, "password123")
      sign_in_page.submit

      expect(sign_in_page).to have_signed_in_message

      pg = AdminDashboardPage.new
      pg.visit_page

      expect(pg).to have_heading
      expect(pg).to have_model("Admin users")
      expect(pg).to have_model("Users")
      expect(pg).to have_model("Countries")
      expect(pg).to have_model("Inspection templates")
      expect(pg).to have_model("Checklist items")
      expect(pg).to have_count
    end
  end
end
