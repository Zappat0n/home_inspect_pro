# frozen_string_literal: true

require "rails_helper"

RSpec.describe InspectionItem, type: :model do
  describe "associations" do
    it "belongs to inspection" do
      inspection = build_stubbed(:inspection)
      inspection_item = build_stubbed(:inspection_item, inspection: inspection)

      expect(inspection_item.inspection).to eq(inspection)
    end

    it "belongs to checklist_item" do
      checklist_item = build_stubbed(:checklist_item)
      inspection_item = build_stubbed(:inspection_item, checklist_item: checklist_item)

      expect(inspection_item.checklist_item).to eq(checklist_item)
    end
  end

  describe "validations" do
    it "is valid with valid attributes" do
      inspection_item = build_stubbed(:inspection_item)

      expect(inspection_item).to be_valid
    end

    it "requires checklist_item_id" do
      inspection_item = build_stubbed(:inspection_item, checklist_item: nil)

      expect(inspection_item).not_to be_valid
    end

    it "requires inspection_id" do
      inspection_item = build_stubbed(:inspection_item, inspection: nil)

      expect(inspection_item).not_to be_valid
    end

    it "enforces uniqueness of checklist_item_id scoped to inspection_id" do
      inspection = create(:inspection)
      checklist_item = create(:checklist_item)
      create(:inspection_item, inspection: inspection, checklist_item: checklist_item)
      duplicate = build(:inspection_item, inspection: inspection, checklist_item: checklist_item)

      expect(duplicate).not_to be_valid
    end

    it "allows same checklist_item_id for different inspections" do
      checklist_item = create(:checklist_item)
      inspection_a = create(:inspection)
      inspection_b = create(:inspection)
      create(:inspection_item, inspection: inspection_a, checklist_item: checklist_item)
      item_b = build(:inspection_item, inspection: inspection_b, checklist_item: checklist_item)

      expect(item_b).to be_valid
    end

    it "allows different checklist_item_id for same inspection" do
      inspection = create(:inspection)
      checklist_item_a = create(:checklist_item)
      checklist_item_b = create(:checklist_item)
      create(:inspection_item, inspection: inspection, checklist_item: checklist_item_a)
      item_b = build(:inspection_item, inspection: inspection, checklist_item: checklist_item_b)

      expect(item_b).to be_valid
    end
  end

  describe "status enum" do
    it "allows ok status" do
      inspection_item = build_stubbed(:inspection_item, status: :ok)

      expect(inspection_item.status).to eq("ok")
    end

    it "allows defect status" do
      inspection_item = build_stubbed(:inspection_item, status: :defect)

      expect(inspection_item.status).to eq("defect")
    end

    it "allows na status" do
      inspection_item = build_stubbed(:inspection_item, status: :na)

      expect(inspection_item.status).to eq("na")
    end

    it "provides predicate methods" do
      ok_item = build_stubbed(:inspection_item, status: :ok)
      defect_item = build_stubbed(:inspection_item, status: :defect)
      na_item = build_stubbed(:inspection_item, status: :na)

      expect(ok_item.ok?).to be true
      expect(defect_item.defect?).to be true
      expect(na_item.na?).to be true
    end
  end

  describe "scopes" do
    describe ".with_defects" do
      it "returns inspection items with defect status" do
        inspection = create(:inspection)
        defect_item = create(:inspection_item, inspection: inspection, status: :defect)
        ok_item = create(:inspection_item, inspection: inspection, status: :ok)

        results = described_class.with_defects

        expect(results).to include(defect_item)
        expect(results).not_to include(ok_item)
      end
    end

    describe ".with_comments" do
      it "returns inspection items with non-empty comments" do
        inspection = create(:inspection)
        item_with_comment = create(:inspection_item, inspection: inspection, comment: "Found a crack")
        item_with_empty_comment = create(:inspection_item, inspection: inspection, comment: "")
        item_with_nil_comment = create(:inspection_item, inspection: inspection, comment: nil)

        results = described_class.with_comments

        expect(results).to include(item_with_comment)
        expect(results).not_to include(item_with_empty_comment)
        expect(results).not_to include(item_with_nil_comment)
      end
    end
  end
end
