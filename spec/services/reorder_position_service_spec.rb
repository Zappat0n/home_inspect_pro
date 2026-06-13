# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReorderPositionService do
  describe "#call" do
    it "reorders records to the specified positions" do
      country = create(:country)
      template = create(:inspection_template, country: country)
      category_a = create(:inspection_template_category, inspection_template: template, position: 0)
      category_b = create(:inspection_template_category, inspection_template: template, position: 1)
      category_c = create(:inspection_template_category, inspection_template: template, position: 2)
      scope = InspectionTemplate::Category.where(inspection_template: template)

      described_class.new(
        scope,
        [
          { id: category_a.id, position: 2 },
          { id: category_b.id, position: 0 },
          { id: category_c.id, position: 1 },
        ],
      ).call

      category_a.reload
      category_b.reload
      category_c.reload

      expect(category_a.position).to eq(2)
      expect(category_b.position).to eq(0)
      expect(category_c.position).to eq(1)
    end

    it "only reorders records matching the scope" do
      country = create(:country)
      template = create(:inspection_template, country: country)
      other_template = create(:inspection_template, country: country)
      category_a = create(:inspection_template_category, inspection_template: template, position: 0)
      category_b = create(:inspection_template_category, inspection_template: template, position: 1)
      other_category = create(:inspection_template_category, inspection_template: other_template, position: 5)
      scope = InspectionTemplate::Category.where(inspection_template: template)

      described_class.new(
        scope,
        [
          { id: category_a.id, position: 1 },
          { id: category_b.id, position: 0 },
        ],
      ).call

      expect(category_a.reload.position).to eq(1)
      expect(category_b.reload.position).to eq(0)
      expect(other_category.reload.position).to eq(5)
    end

    it "handles reordering a single record" do
      country = create(:country)
      template = create(:inspection_template, country: country)
      category = create(:inspection_template_category, inspection_template: template, position: 0)
      scope = InspectionTemplate::Category.where(inspection_template: template)

      described_class.new(
        scope,
        [
          { id: category.id, position: 5 },
        ],
      ).call

      expect(category.reload.position).to eq(5)
    end

    it "handles reordering with gaps in position values" do
      country = create(:country)
      template = create(:inspection_template, country: country)
      category_a = create(:inspection_template_category, inspection_template: template, position: 0)
      category_b = create(:inspection_template_category, inspection_template: template, position: 1)
      category_c = create(:inspection_template_category, inspection_template: template, position: 2)
      scope = InspectionTemplate::Category.where(inspection_template: template)

      described_class.new(
        scope,
        [
          { id: category_a.id, position: 10 },
          { id: category_b.id, position: 20 },
          { id: category_c.id, position: 30 },
        ],
      ).call

      category_a.reload
      category_b.reload
      category_c.reload

      expect(category_a.position).to eq(10)
      expect(category_b.position).to eq(20)
      expect(category_c.position).to eq(30)
    end
  end
end
