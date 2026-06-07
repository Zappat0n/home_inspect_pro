# frozen_string_literal: true

class Inspections::InitializeChecklistService
  def initialize(inspection)
    @inspection = inspection
  end

  def call
    checklist_items = inspection.inspection_template.checklist_items.ordered

    checklist_items.each do |item|
      inspection.inspection_items.create!(
        checklist_item: item,
        status: :na, # Default status
      )
    end
  end

  private

  attr_reader :inspection
end
