# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Devise Sessions", type: :feature do
  describe "sign in" do
    it "signs in with valid credentials" do
      user = create(:user, password: "password123")

      pg = SignInPage.new
      pg.visit_page
      pg.fill_in_with(user.email, "password123")
      pg.submit

      expect(pg).to have_signed_in_message
    end

    it "shows error with invalid password" do
      user = create(:user, password: "password123")

      pg = SignInPage.new
      pg.visit_page
      pg.fill_in_with(user.email, "wrongpassword")
      pg.submit

      expect(pg).to have_invalid_credentials_message
    end

    it "shows error with unregistered email" do
      pg = SignInPage.new
      pg.visit_page
      pg.fill_in_with("nonexistent@example.com", "password123")
      pg.submit

      expect(pg).to have_not_found_message
    end
  end

  describe "sign out" do
    it "signs out successfully" do
      user = create(:user, password: "password123")

      pg = SignInPage.new
      pg.visit_page
      pg.fill_in_with(user.email, "password123")
      pg.submit
      expect(pg).to have_signed_in_message

      pg.sign_out

      expect(pg).to have_signed_out_message
    end
  end
end
