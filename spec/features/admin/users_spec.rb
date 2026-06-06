# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin Users", type: :feature do
  describe "listing" do
    it "displays all users in the system" do
      admin_user = create(:admin_user)
      country = create(:country)
      user1 = create(:user, email: "user1@example.com", country: country)
      user2 = create(:user, email: "user2@example.com", country: country)

      sign_in_page = AdminSignInPage.new
      sign_in_page.visit_page
      sign_in_page.fill_in_with(admin_user.email, "password123")
      sign_in_page.submit

      pg = AdminUsersPage.new
      pg.visit_page

      expect(pg).to have_user(user1)
      expect(pg).to have_user(user2)
    end
  end

  describe "creation" do
    it "creates a new user with valid data" do
      admin_user = create(:admin_user)
      country = create(:country)

      sign_in_page = AdminSignInPage.new
      sign_in_page.visit_page
      sign_in_page.fill_in_with(admin_user.email, "password123")
      sign_in_page.submit

      pg = AdminNewUserPage.new
      pg.visit_new_page
      pg.fill_in_with(
        email: "newuser@example.com",
        password: "password123",
        password_confirmation: "password123",
        country: country,
        subscribed: false,
      )
      pg.submit

      expect(User.find_by(email: "newuser@example.com")).to be_present
      expect(pg).to have_success_created_message
    end

    it "shows validation error with blank email" do
      admin_user = create(:admin_user)
      country = create(:country)

      sign_in_page = AdminSignInPage.new
      sign_in_page.visit_page
      sign_in_page.fill_in_with(admin_user.email, "password123")
      sign_in_page.submit

      pg = AdminNewUserPage.new
      pg.visit_new_page
      pg.fill_in_with(
        email: "",
        password: "password123",
        password_confirmation: "password123",
        country: country,
        subscribed: false,
      )
      pg.submit

      expect(pg).to have_error_message
    end
  end

  describe "editing" do
    it "updates a user email" do
      admin_user = create(:admin_user)
      country = create(:country)
      user = create(:user, email: "original@example.com", country: country)

      sign_in_page = AdminSignInPage.new
      sign_in_page.visit_page
      sign_in_page.fill_in_with(admin_user.email, "password123")
      sign_in_page.submit

      pg = AdminNewUserPage.new
      pg.visit_edit_page(user)
      pg.fill_in_with(email: "updated@example.com")
      pg.submit

      expect(pg).to have_success_updated_message
      expect(user.reload.email).to eq("updated@example.com")
    end
  end

  describe "deletion" do
    it "deletes a user" do
      admin_user = create(:admin_user)
      country = create(:country)
      user = create(:user, email: "todelete@example.com", country: country)

      sign_in_page = AdminSignInPage.new
      sign_in_page.visit_page
      sign_in_page.fill_in_with(admin_user.email, "password123")
      sign_in_page.submit

      pg = AdminUsersPage.new
      pg.visit_page
      expect(pg).to have_user(user)

      expect do
        pg.click_delete(user)
        click_button "Yes, I'm sure"
      end.to change { User.count }.by(-1)

      expect(pg).to have_success_deleted_message
      expect(pg).to have_no_user(user)
    end
  end

  describe "viewing" do
    it "shows user details" do
      admin_user = create(:admin_user)
      country = create(:country)
      user = create(:user, email: "showtest@example.com", country: country)

      sign_in_page = AdminSignInPage.new
      sign_in_page.visit_page
      sign_in_page.fill_in_with(admin_user.email, "password123")
      sign_in_page.submit

      pg = AdminUsersPage.new
      pg.visit_page
      expect(pg).to have_user(user)

      pg.click_show(user)

      expect(pg).to have_user(user)
    end
  end
end
