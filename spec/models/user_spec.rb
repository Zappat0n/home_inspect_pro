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

  describe "subscription helpers" do
    include ActiveSupport::Testing::TimeHelpers

    describe "#subscribed?" do
      it "returns true when user has an active subscription" do
        user = create(:user)
        user.set_payment_processor(:paddle_billing)
        user.payment_processor.update_column(:processor_id, "ctm_test123")
        Pay::PaddleBilling::Subscription.create!(
          customer: user.payment_processor,
          name: "default",
          processor_id: "sub_test123",
          processor_plan: "pri_monthly",
          status: "active",
          current_period_start: Time.current,
          current_period_end: 1.month.from_now,
        )

        expect(user.subscribed?).to be true
      end

      it "returns false when no Pay subscription exists" do
        user = build_stubbed(:user)

        expect(user.subscribed?).to be_falsy
      end
    end

    describe "#on_trial?" do
      it "returns true when trial_ends_at is in the future" do
        user = build_stubbed(:user)

        expect(user.on_trial?).to be true
      end

      it "returns false when trial_ends_at is nil" do
        user = build_stubbed(:user, trial_ends_at: nil)

        expect(user.on_trial?).to be_falsy
      end

      it "returns false when trial_ends_at is in the past" do
        user = create(:user)

        travel_to(8.days.from_now) do
          expect(user.on_trial?).to be_falsy
        end
      end
    end
  end
end
