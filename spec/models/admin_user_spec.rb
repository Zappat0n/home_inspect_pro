# frozen_string_literal: true

require "rails_helper"

RSpec.describe AdminUser, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      admin_user = build_stubbed(:admin_user)

      expect(admin_user).to be_valid
    end

    it "is invalid without an email" do
      admin_user = build_stubbed(:admin_user, email: nil)

      expect(admin_user).not_to be_valid
      expect(admin_user.errors[:email]).to include("can't be blank")
    end

    it "is invalid with a malformed email" do
      admin_user = build(:admin_user, email: "invalid")

      expect(admin_user).not_to be_valid
      expect(admin_user.errors[:email]).to include("is invalid")
    end

    it "is invalid without a password" do
      admin_user = build_stubbed(:admin_user, password: nil)

      expect(admin_user).not_to be_valid
      expect(admin_user.errors[:password]).to include("can't be blank")
    end

    it "is invalid with a short password" do
      admin_user = build_stubbed(:admin_user, password: "short", password_confirmation: "short")

      expect(admin_user).not_to be_valid
      expect(admin_user.errors[:password]).to include("is too short (minimum is 6 characters)")
    end

    it "is invalid with a duplicate email" do
      create(:admin_user, email: "duplicate@example.com")
      admin_user = build(:admin_user, email: "duplicate@example.com")

      expect(admin_user).not_to be_valid
      expect(admin_user.errors[:email]).to include("has already been taken")
    end
  end
end
