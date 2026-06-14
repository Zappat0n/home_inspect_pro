# frozen_string_literal: true

class AddDefectDetailFieldsToInspectionItems < ActiveRecord::Migration[8.1]
  def change
    change_table(:inspection_items, bulk: true) do |t|
      t.integer(:repair_priority)
    end
  end
end
