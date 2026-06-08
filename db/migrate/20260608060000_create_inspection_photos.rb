# frozen_string_literal: true

class CreateInspectionPhotos < ActiveRecord::Migration[8.2]
  def change
    create_table(:inspection_photos, charset: "utf8mb4") do |t|
      t.references(:inspection, null: false, foreign_key: true)
      t.references(:checklist_item, null: false, foreign_key: true)
      t.integer(:position, null: false, default: 0)

      t.timestamps
    end

    add_index(
      :inspection_photos,
      [:inspection_id, :position],
      unique: true,
      name: "idx_inspection_photos_on_inspection_and_position",
    )
  end
end
