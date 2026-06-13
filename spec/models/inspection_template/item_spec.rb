require "rails_helper"

RSpec.describe InspectionTemplate::Item, type: :model do
  describe "associations" do
    it "belongs to an inspection template" do
      item = build_stubbed(:inspection_template_item)

      expect(item.inspection_template).to be_present
    end

    it "belongs to an inspection template category" do
      item = build_stubbed(:inspection_template_item)

      expect(item.inspection_template_category).to be_present
    end
  end

  describe "validations" do
    it "is invalid without a name" do
      item = build(:inspection_template_item, name: nil)

      expect(item).not_to be_valid
      expect(item.errors[:name]).to include("can't be blank")
    end

    it "is invalid without a position" do
      item = build(:inspection_template_item, position: nil)

      expect(item).not_to be_valid
      expect(item.errors[:position]).to include("can't be blank")
    end

    it "is invalid with a duplicate position scoped to the same category" do
      category = create(:inspection_template_category)
      create(:inspection_template_item, inspection_template_category: category, position: 1)
      duplicate = build(:inspection_template_item, inspection_template_category: category, position: 1)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:position]).to include("has already been taken")
    end

    it "allows the same position in different categories" do
      template = create(:inspection_template)
      category1 = create(:inspection_template_category, inspection_template: template)
      category2 = create(:inspection_template_category, inspection_template: template)
      create(:inspection_template_item, inspection_template_category: category1, position: 1)
      different = build(:inspection_template_item, inspection_template_category: category2, position: 1)

      expect(different).to be_valid
    end
  end

  describe "enum" do
    it "defines severity values and query methods" do
      item = build_stubbed(:inspection_template_item, severity: :critical)

      expect(item).to be_critical
      expect(item.severity).to eq("critical")
    end

    it "allows major severity" do
      item = build_stubbed(:inspection_template_item, severity: :major)

      expect(item).to be_major
    end

    it "allows minor severity" do
      item = build_stubbed(:inspection_template_item, severity: :minor)

      expect(item).to be_minor
    end

    it "allows info severity" do
      item = build_stubbed(:inspection_template_item, severity: :info)

      expect(item).to be_info
    end
  end

  describe "scopes" do
    it "orders by position" do
      category = create(:inspection_template_category)
      item2 = create(:inspection_template_item, inspection_template_category: category, position: 2)
      item1 = create(:inspection_template_item, inspection_template_category: category, position: 1)
      item3 = create(:inspection_template_item, inspection_template_category: category, position: 3)

      expect(described_class.ordered).to eq([item1, item2, item3])
    end
  end
end
