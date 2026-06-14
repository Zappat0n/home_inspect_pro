# frozen_string_literal: true

require "rails_helper"

RSpec.describe InspectionPhoto, type: :model do
  describe "associations" do
    it "belongs to inspection" do
      inspection = build_stubbed(:inspection)
      inspection_photo = build_stubbed(:inspection_photo, inspection: inspection)

      expect(inspection_photo.inspection).to eq(inspection)
    end

    it "belongs to checklist_item" do
      checklist_item = build_stubbed(:checklist_item)
      inspection_photo = build_stubbed(:inspection_photo, checklist_item: checklist_item)

      expect(inspection_photo.checklist_item).to eq(checklist_item)
    end

    it "has one attached photo" do
      inspection_photo = build(:inspection_photo)
      inspection_photo.photo.attach(
        io: File.open(Rails.root.join("spec/fixtures/files/test.txt")),
        filename: "test.txt",
        content_type: "text/plain",
      )
      inspection_photo.save!

      expect(inspection_photo.photo).to be_attached
      expect(inspection_photo).to be_valid
    end
  end

  describe "validations" do
    it "requires position" do
      inspection_photo = build_stubbed(:inspection_photo, position: nil)

      expect(inspection_photo).not_to be_valid
    end

    it "requires photo to be attached" do
      inspection_photo = build(:inspection_photo)

      expect(inspection_photo).not_to be_valid
    end

    it "enforces uniqueness of position scoped to inspection_id" do
      inspection = create(:inspection)
      checklist_item = create(:checklist_item)
      existing = build(:inspection_photo, inspection: inspection, checklist_item: checklist_item, position: 0)
      existing.photo.attach(
        io: File.open(Rails.root.join("spec/fixtures/files/test.txt")),
        filename: "test.txt",
        content_type: "text/plain",
      )
      existing.save!
      duplicate = build(:inspection_photo, inspection: inspection, checklist_item: checklist_item, position: 0)

      expect(duplicate).not_to be_valid
    end
  end

  describe "scopes" do
    describe ".ordered" do
      it "returns photos in position order" do
        inspection = create(:inspection)
        checklist_item = create(:checklist_item)
        first_photo = build(:inspection_photo, inspection: inspection, checklist_item: checklist_item, position: 0)
        first_photo.photo.attach(
          io: File.open(Rails.root.join("spec/fixtures/files/test.txt")),
          filename: "test.txt",
          content_type: "text/plain",
        )
        first_photo.save!
        second_photo = build(:inspection_photo, inspection: inspection, checklist_item: checklist_item, position: 1)
        second_photo.photo.attach(
          io: File.open(Rails.root.join("spec/fixtures/files/test.txt")),
          filename: "test.txt",
          content_type: "text/plain",
        )
        second_photo.save!
        third_photo = build(:inspection_photo, inspection: inspection, checklist_item: checklist_item, position: 2)
        third_photo.photo.attach(
          io: File.open(Rails.root.join("spec/fixtures/files/test.txt")),
          filename: "test.txt",
          content_type: "text/plain",
        )
        third_photo.save!

        expect(described_class.ordered).to eq([first_photo, second_photo, third_photo])
      end
    end
  end

  describe "custom fields" do
    it "allows setting caption" do
      inspection_photo = build_stubbed(:inspection_photo, caption: "Front door")

      expect(inspection_photo.caption).to eq("Front door")
    end
  end
end
