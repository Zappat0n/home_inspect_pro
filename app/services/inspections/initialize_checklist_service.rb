# frozen_string_literal: true

class Inspections::InitializeChecklistService
  def initialize(inspection)
    @inspection = inspection
  end

  def call
    items = inspection.inspection_template.items.ordered

    items.each do |item|
      inspection.inspection_items.create!(
        checklist_item: item,
        status: :na, # Default status
      )
    end
  end

  private

  attr_reader :inspection
end
