require "rails_helper"

RSpec.describe InspectionTemplate, type: :model do
  describe "associations" do
    it "belongs to a country" do
      country = build_stubbed(:country)
      inspection_template = build_stubbed(:inspection_template, country: country)

      expect(inspection_template.country).to eq(country)
    end

    it "has many checklist items ordered by position" do
      inspection_template = create(:inspection_template)
      item2 = create(:checklist_item, inspection_template: inspection_template, position: 2)
      item1 = create(:checklist_item, inspection_template: inspection_template, position: 1)
      item3 = create(:checklist_item, inspection_template: inspection_template, position: 3)

      expect(inspection_template.checklist_items).to eq([item1, item2, item3])
    end

    it "destroys associated checklist items on destroy" do
      inspection_template = create(:inspection_template)
      create(:checklist_item, inspection_template: inspection_template)

      expect { inspection_template.destroy! }.to change { ChecklistItem.count }.by(-1)
    end
  end

  describe "validations" do
    it "is invalid without a name" do
      inspection_template = build_stubbed(:inspection_template, name: nil)

      expect(inspection_template).not_to be_valid
      expect(inspection_template.errors[:name]).to include("can't be blank")
    end
  end

  describe "scopes" do
    it "returns only published templates" do
      published_template = create(:inspection_template, published: true)
      create(:inspection_template, published: false)

      expect(described_class.published).to contain_exactly(published_template)
    end
  end
end
