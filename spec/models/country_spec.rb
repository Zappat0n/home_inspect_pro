# == Schema Information
#
# Table name: countries
#
#  id         :bigint           not null, primary key
#  available  :boolean
#  code       :string
#  locale     :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_countries_on_code  (code) UNIQUE
#
require "rails_helper"

RSpec.describe Country, type: :model do
  describe "associations" do
    it "has many users" do
      country = create(:country)
      user1 = create(:user, country: country)
      user2 = create(:user, country: country)

      expect(country.users).to include(user1, user2)
    end
  end

  describe "attributes" do
    it "is valid with valid attributes" do
      country = build_stubbed(:country)

      expect(country).to be_valid
    end

    it "allows setting name" do
      country = build_stubbed(:country, name: "Spain")

      expect(country.name).to eq("Spain")
    end

    it "allows setting code" do
      country = build_stubbed(:country, code: "ES")

      expect(country.code).to eq("ES")
    end

    it "allows setting locale" do
      country = build_stubbed(:country, locale: "es")

      expect(country.locale).to eq("es")
    end

    it "defaults available to true" do
      country = build_stubbed(:country)

      expect(country.available).to be true
    end
  end

  describe "validations" do
    it "is invalid without a name" do
      country = build_stubbed(:country, name: nil)

      expect(country).not_to be_valid
      expect(country.errors[:name]).to include("can't be blank")
    end

    it "is invalid without a code" do
      country = build_stubbed(:country, code: nil)

      expect(country).not_to be_valid
      expect(country.errors[:code]).to include("can't be blank")
    end

    it "is invalid with a duplicate code" do
      create(:country, code: "US")
      country = build(:country, code: "US")

      expect(country).not_to be_valid
      expect(country.errors[:code]).to include("has already been taken")
    end

    it "is invalid without a locale" do
      country = build_stubbed(:country, locale: nil)

      expect(country).not_to be_valid
      expect(country.errors[:locale]).to include("can't be blank")
    end
  end
end
