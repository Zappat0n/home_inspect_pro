# frozen_string_literal: true

require "rails_helper"

RSpec.describe InspectionTemplate::Category, type: :model do
  describe "associations" do
    it "belongs to an inspection template" do
      category = build_stubbed(:inspection_template_category)

      expect(category.inspection_template).to be_present
    end

    it "has many items" do
      category = create(:inspection_template_category)
      item1 = create(:inspection_template_item, inspection_template_category: category, position: 1)
      item2 = create(:inspection_template_item, inspection_template_category: category, position: 2)

      expect(category.items).to contain_exactly(item1, item2)
    end

    it "destroys dependent items on destroy" do
      category = create(:inspection_template_category)
      create(:inspection_template_item, inspection_template_category: category)

      expect { category.destroy }.to change { described_class.count }.by(-1)
    end
  end

  describe "validations" do
    it "is valid with valid attributes" do
      category = build_stubbed(:inspection_template_category)

      expect(category).to be_valid
    end

    it "is invalid without a name" do
      category = build(:inspection_template_category, name: nil)

      expect(category).not_to be_valid
      expect(category.errors[:name]).to include("can't be blank")
    end

    it "is invalid with a duplicate name within the same template" do
      template = create(:inspection_template)
      create(:inspection_template_category, inspection_template: template, name: "Electrical")
      duplicate = build(:inspection_template_category, inspection_template: template, name: "Electrical")

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name]).to include("has already been taken")
    end

    it "allows the same name in different templates" do
      create(:inspection_template_category, name: "Plumbing")
      different = build(:inspection_template_category, name: "Plumbing")

      expect(different).to be_valid
    end
  end

  describe "scopes" do
    it "orders by position" do
      template = create(:inspection_template)
      cat2 = create(:inspection_template_category, inspection_template: template, position: 2)
      cat1 = create(:inspection_template_category, inspection_template: template, position: 1)
      cat3 = create(:inspection_template_category, inspection_template: template, position: 3)

      expect(described_class.ordered).to eq([cat1, cat2, cat3])
    end
  end
end
