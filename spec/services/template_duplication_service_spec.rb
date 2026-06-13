# frozen_string_literal: true

require "rails_helper"

RSpec.describe TemplateDuplicationService do
  describe "#call" do
    it "duplicates a system template and assigns it to the user" do
      country = create(:country)
      user = create(:user, country: country)
      template = create(:inspection_template, country: country, published: true, template_type: :system)
      roof_category = create(:inspection_template_category, inspection_template: template, name: "Roof")
      electrical_category = create(:inspection_template_category, inspection_template: template, name: "Electrical")
      create(
        :checklist_item,
        inspection_template: template,
        inspection_template_category: roof_category,
        name: "Shingles",
        description: "Check for damaged shingles",
        severity: :major,
        position: 1,
        allows_photo: true,
      )
      create(
        :checklist_item,
        inspection_template: template,
        inspection_template_category: electrical_category,
        name: "Outlets",
        description: "Test all outlets",
        severity: :critical,
        position: 2,
        allows_photo: false,
      )

      new_template = described_class.new(template, user).call

      expect(new_template).to be_custom
      expect(new_template.user).to eq(user)
      expect(new_template.name).to eq("Copy of #{template.name}")
      expect(new_template.country).to eq(country)
      expect(new_template.published).to be(false)

      expect(new_template.items.count).to eq(2)
      expect(new_template.items.find_by(position: 1)).to have_attributes(
        name: "Shingles",
        description: "Check for damaged shingles",
        severity: "major",
        position: 1,
        allows_photo: true,
      )
      expect(new_template.items.find_by(position: 1).inspection_template_category.name).to eq("Roof")
      expect(new_template.items.find_by(position: 2)).to have_attributes(
        name: "Outlets",
        description: "Test all outlets",
        severity: "critical",
        position: 2,
        allows_photo: false,
      )
      expect(new_template.items.find_by(position: 2).inspection_template_category.name).to eq("Electrical")

      template.reload
      expect(template).to be_system
      expect(template.items.count).to eq(2)
    end
  end
end
