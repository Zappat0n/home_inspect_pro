class CreateInspectionTemplates < ActiveRecord::Migration[8.2]
  def change
    create_table(:inspection_templates) do |t|
      t.string(:name)
      t.references(:country, null: false, foreign_key: true)
      t.string(:category)
      t.boolean(:published, default: false, null: false)

      t.timestamps
    end

    add_index(:inspection_templates, :name)
  end
end
