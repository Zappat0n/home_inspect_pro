require "rails_helper"

RSpec.describe Inspection, type: :model do
  describe "associations" do
    it "belongs to a user" do
      user = build_stubbed(:user)
      inspection = build_stubbed(:inspection, user: user)

      expect(inspection.user).to eq(user)
    end

    it "belongs to an inspection template" do
      inspection_template = build_stubbed(:inspection_template)
      inspection = build_stubbed(:inspection, inspection_template: inspection_template)

      expect(inspection.inspection_template).to eq(inspection_template)
    end

    it "is destroyed when its user is destroyed" do
      inspection = create(:inspection)

      expect { inspection.user.destroy! }.to change { described_class.count }.by(-1)
    end

    it "is destroyed when its inspection template is destroyed" do
      inspection = create(:inspection)

      expect { inspection.inspection_template.destroy! }.to change { described_class.count }.by(-1)
    end
  end

  describe "validations" do
    it "is invalid without a property address" do
      inspection = build_stubbed(:inspection, property_address: nil)

      expect(inspection).not_to be_valid
      expect(inspection.errors[:property_address]).to include("can't be blank")
    end

    it "is invalid without a client name" do
      inspection = build_stubbed(:inspection, client_name: nil)

      expect(inspection).not_to be_valid
      expect(inspection.errors[:client_name]).to include("can't be blank")
    end

    it "is valid with all required attributes" do
      inspection = build_stubbed(:inspection)

      expect(inspection).to be_valid
    end
  end

  describe "status enum" do
    it "defaults to draft status" do
      inspection = build_stubbed(:inspection)

      expect(inspection).to be_draft
    end

    it "can be completed" do
      inspection = build_stubbed(:inspection, status: :completed)

      expect(inspection).to be_completed
    end
  end
end
