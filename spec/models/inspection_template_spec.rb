require "rails_helper"

RSpec.describe InspectionTemplate, type: :model do
  describe "associations" do
    it "belongs to a country" do
      country = build_stubbed(:country)
      inspection_template = build_stubbed(:inspection_template, country: country)

      expect(inspection_template.country).to eq(country)
    end

    it "belongs to an optional user" do
      user = build_stubbed(:user)
      inspection_template = build_stubbed(:inspection_template, :custom, user: user)

      expect(inspection_template.user).to eq(user)
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

    it "destroys associated inspections on destroy" do
      inspection_template = create(:inspection_template)
      create(:inspection, inspection_template: inspection_template)

      expect { inspection_template.destroy! }.to change { Inspection.count }.by(-1)
    end
  end

  describe "enum" do
    it "defines system as 0" do
      expect(described_class.template_types[:system]).to eq(0)
    end

    it "defines custom as 1" do
      expect(described_class.template_types[:custom]).to eq(1)
    end

    it "returns true for system? when template_type is system" do
      inspection_template = build_stubbed(:inspection_template)

      expect(inspection_template).to be_system
    end

    it "returns true for custom? when template_type is custom" do
      inspection_template = build_stubbed(:inspection_template, :custom)

      expect(inspection_template).to be_custom
    end
  end

  describe "validations" do
    it "is invalid without a name" do
      inspection_template = build_stubbed(:inspection_template, name: nil)

      expect(inspection_template).not_to be_valid
      expect(inspection_template.errors[:name]).to include("can't be blank")
    end

    it "prevents creating a 6th custom template for the same user" do
      user = create(:user)
      create_list(:inspection_template, 5, :custom, user: user)
      sixth = build(:inspection_template, :custom, user: user)

      expect(sixth).not_to be_valid
      expect(sixth.errors[:base]).to include("Maximum of 5 custom templates allowed")
    end

    it "allows creating up to 5 custom templates for the same user" do
      user = create(:user)
      template = build(:inspection_template, :custom, user: user)
      create_list(:inspection_template, 4, :custom, user: user)

      expect(template).to be_valid
    end

    it "does not limit system templates for a user with many custom templates" do
      user = create(:user)
      create_list(:inspection_template, 5, :custom, user: user)
      system_template = build(:inspection_template, user: user)

      expect(system_template).to be_valid
    end
  end

  describe "scopes" do
    it "returns only published templates" do
      published_template = create(:inspection_template, published: true)
      create(:inspection_template, published: false)

      expect(described_class.published).to contain_exactly(published_template)
    end

    it "returns only system templates" do
      system_template = create(:inspection_template)
      create(:inspection_template, :custom)

      expect(described_class.system_templates).to contain_exactly(system_template)
    end

    it "returns only custom templates" do
      create(:inspection_template)
      custom_template = create(:inspection_template, :custom)

      expect(described_class.custom_templates).to contain_exactly(custom_template)
    end

    it "returns system templates and the given user's custom templates" do
      user = create(:user)
      other_user = create(:user)
      system_template = create(:inspection_template)
      custom_template = create(:inspection_template, :custom, user: user)
      create(:inspection_template, :custom, user: other_user)

      expect(described_class.for_user(user))
        .to contain_exactly(system_template, custom_template)
    end
  end
end
