class CreateChecklistItems < ActiveRecord::Migration[8.2]
  def change
    create_table(:checklist_items) do |t|
      t.references(:inspection_template, null: false, foreign_key: true)
      t.string(:name)
      t.text(:description)
      t.string(:category)
      t.integer(:severity)
      t.integer(:position)
      t.boolean(:allows_photo, default: false, null: false)

      t.timestamps
    end

    add_index(
      :checklist_items,
      [:inspection_template_id, :position],
      unique: true,
      name: "idx_checklist_items_on_template_and_position",
    )
  end
end
