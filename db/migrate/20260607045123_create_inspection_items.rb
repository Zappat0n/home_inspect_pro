# frozen_string_literal: true

class CreateInspectionItems < ActiveRecord::Migration[8.2]
  def change
    create_table(:inspection_items, charset: "utf8mb4") do |t|
      t.references(:inspection, null: false, foreign_key: true)
      t.references(:checklist_item, null: false, foreign_key: true)
      t.integer(:status)
      t.text(:comment)

      t.timestamps
    end

    add_index(
      :inspection_items,
      [:inspection_id, :checklist_item_id],
      unique: true,
      name: "idx_inspection_items_on_inspection_and_item",
    )
  end
end
