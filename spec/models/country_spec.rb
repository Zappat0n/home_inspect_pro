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
end
