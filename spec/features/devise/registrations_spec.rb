# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Devise Registrations", type: :feature do
  describe "sign up" do
    it "registers a new user with valid data" do
      geocoder_result = instance_double(Geocoder::Result::Base, country_code: "US", country: "United States")
      allow(Geocoder).to receive(:search).and_return([geocoder_result])
      create(:country, code: "US")

      pg = SignUpPage.new
      pg.visit_page
      pg.fill_in_with(
        email: "newuser@example.com",
        password: "password123",
        password_confirmation: "password123",
      )
      pg.submit

      expect(pg).to have_signed_up_message
    end

    it "shows error with mismatched passwords" do
      geocoder_result = instance_double(Geocoder::Result::Base, country_code: "US", country: "United States")
      allow(Geocoder).to receive(:search).and_return([geocoder_result])
      create(:country, code: "US")

      pg = SignUpPage.new
      pg.visit_page
      pg.fill_in_with(
        email: "newuser@example.com",
        password: "password123",
        password_confirmation: "different",
      )
      pg.submit

      expect(pg).to have_password_confirmation_mismatch_message
    end

    it "shows error with blank email" do
      geocoder_result = instance_double(Geocoder::Result::Base, country_code: "US", country: "United States")
      allow(Geocoder).to receive(:search).and_return([geocoder_result])
      create(:country, code: "US")

      pg = SignUpPage.new
      pg.visit_page
      pg.fill_in_with(
        email: "",
        password: "password123",
        password_confirmation: "password123",
      )
      pg.submit

      expect(pg).to have_blank_email_message
    end
  end
end
