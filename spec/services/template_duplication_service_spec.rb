# frozen_string_literal: true

require "rails_helper"

RSpec.describe TemplateDuplicationService do
  describe "#call" do
    it "duplicates a system template and assigns it to the user" do
      country = create(:country)
      user = create(:user, country: country)
      template = create(:inspection_template, country: country, published: true, template_type: :system)
      create(
        :checklist_item,
        inspection_template: template,
        category: "Roof",
        name: "Shingles",
        description: "Check for damaged shingles",
        severity: :major,
        position: 1,
        allows_photo: true,
      )
      create(
        :checklist_item,
        inspection_template: template,
        category: "Electrical",
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

      expect(new_template.checklist_items.count).to eq(2)
      expect(new_template.checklist_items.find_by(position: 1)).to have_attributes(
        name: "Shingles",
        description: "Check for damaged shingles",
        category: "Roof",
        severity: "major",
        position: 1,
        allows_photo: true,
      )
      expect(new_template.checklist_items.find_by(position: 2)).to have_attributes(
        name: "Outlets",
        description: "Test all outlets",
        category: "Electrical",
        severity: "critical",
        position: 2,
        allows_photo: false,
      )

      template.reload
      expect(template).to be_system
      expect(template.checklist_items.count).to eq(2)
    end
  end
end
