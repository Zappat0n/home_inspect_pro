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

  describe "custom fields" do
    it "allows setting weather_conditions" do
      inspection = build_stubbed(:inspection, weather_conditions: "Sunny")

      expect(inspection.weather_conditions).to eq("Sunny")
    end

    it "allows setting utilities_status" do
      utilities = { "electricity" => "connected", "water" => "connected" }
      inspection = build_stubbed(:inspection, utilities_status: utilities)

      expect(inspection.utilities_status).to eq(utilities)
    end

    it "allows setting property_size" do
      inspection = build_stubbed(:inspection, property_size: 1500)

      expect(inspection.property_size).to eq(1500)
    end

    it "allows setting year_built" do
      inspection = build_stubbed(:inspection, year_built: 1985)

      expect(inspection.year_built).to eq(1985)
    end

    it "has one attached property_cover_photo" do
      inspection = create(:inspection)

      inspection.property_cover_photo.attach(
        io: File.open(Rails.root.join("spec/fixtures/files/test.txt")),
        filename: "cover.txt",
        content_type: "text/plain",
      )
      inspection.save!

      expect(inspection.property_cover_photo).to be_attached
    end
  end
end
