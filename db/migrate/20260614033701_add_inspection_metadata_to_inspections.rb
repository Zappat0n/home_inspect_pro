# frozen_string_literal: true

class AddInspectionMetadataToInspections < ActiveRecord::Migration[8.1]
  def change
    change_table(:inspections, bulk: true) do |t|
      t.string(:weather_conditions)
      t.jsonb(:utilities_status)
      t.integer(:property_size)
      t.integer(:year_built)
    end
  end
end
