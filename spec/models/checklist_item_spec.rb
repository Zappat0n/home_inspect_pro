require "rails_helper"

RSpec.describe ChecklistItem, type: :model do
  describe "associations" do
    it "belongs to an inspection template" do
      inspection_template = build_stubbed(:inspection_template)
      checklist_item = build_stubbed(:checklist_item, inspection_template: inspection_template)

      expect(checklist_item.inspection_template).to eq(inspection_template)
    end
  end

  describe "validations" do
    it "is invalid without a name" do
      checklist_item = build_stubbed(:checklist_item, name: nil)

      expect(checklist_item).not_to be_valid
      expect(checklist_item.errors[:name]).to include("can't be blank")
    end

    it "is invalid without a position" do
      checklist_item = build_stubbed(:checklist_item, position: nil)

      expect(checklist_item).not_to be_valid
      expect(checklist_item.errors[:position]).to include("can't be blank")
    end

    it "is invalid with a duplicate position scoped to the same template" do
      inspection_template = create(:inspection_template)
      create(:checklist_item, inspection_template: inspection_template, position: 1)
      duplicate = build(:checklist_item, inspection_template: inspection_template, position: 1)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:position]).to include("has already been taken")
    end

    it "allows the same position in different templates" do
      template1 = create(:inspection_template)
      template2 = create(:inspection_template)
      create(:checklist_item, inspection_template: template1, position: 1)
      different = build(:checklist_item, inspection_template: template2, position: 1)

      expect(different).to be_valid
    end
  end

  describe "enum" do
    it "defines severity values and query methods" do
      checklist_item = build_stubbed(:checklist_item, severity: :critical)

      expect(checklist_item).to be_critical
      expect(checklist_item.severity).to eq("critical")
    end

    it "allows major severity" do
      checklist_item = build_stubbed(:checklist_item, severity: :major)

      expect(checklist_item).to be_major
    end

    it "allows minor severity" do
      checklist_item = build_stubbed(:checklist_item, severity: :minor)

      expect(checklist_item).to be_minor
    end

    it "allows info severity" do
      checklist_item = build_stubbed(:checklist_item, severity: :info)

      expect(checklist_item).to be_info
    end
  end

  describe "scopes" do
    it "orders by position" do
      inspection_template = create(:inspection_template)
      item2 = create(:checklist_item, inspection_template: inspection_template, position: 2)
      item1 = create(:checklist_item, inspection_template: inspection_template, position: 1)
      item3 = create(:checklist_item, inspection_template: inspection_template, position: 3)

      expect(described_class.ordered).to eq([item1, item2, item3])
    end
  end
end
