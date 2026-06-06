# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  subscribed             :boolean          default(FALSE)
#  trial_ends_at          :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  country_id             :bigint           not null
#  stripe_customer_id     :string
#
# Indexes
#
#  index_users_on_country_id            (country_id)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (country_id => countries.id)
#
require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it "belongs to a country" do
      country = create(:country)
      user = build_stubbed(:user, country: country)

      expect(user.country).to eq(country)
    end

    it "requires a country" do
      user = build_stubbed(:user, country: nil)

      expect(user).not_to be_valid
    end
  end

  describe "devise modules" do
    it "is valid with valid attributes" do
      user = build_stubbed(:user)

      expect(user).to be_valid
    end

    it "requires an email" do
      user = build_stubbed(:user, email: nil)

      expect(user).not_to be_valid
    end

    it "requires a password" do
      user = build_stubbed(:user, password: nil)

      expect(user).not_to be_valid
    end

    it "requires password confirmation to match" do
      user = build_stubbed(:user, password_confirmation: "different")

      expect(user).not_to be_valid
    end
  end

  describe "custom fields" do
    it "defaults subscribed to false" do
      user = build_stubbed(:user)

      expect(user.subscribed).to be false
    end

    it "allows setting trial_ends_at" do
      trial_date = 14.days.from_now
      user = build_stubbed(:user, trial_ends_at: trial_date)

      expect(user.trial_ends_at).to be_within(1.second).of(trial_date)
    end

    it "allows setting stripe_customer_id" do
      user = build_stubbed(:user, stripe_customer_id: "cus_123")

      expect(user.stripe_customer_id).to eq("cus_123")
    end
  end
end
