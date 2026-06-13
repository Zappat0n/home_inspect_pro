class AddUserAndTypeToInspectionTemplates < ActiveRecord::Migration[8.1]
  def up
    change_table(:inspection_templates, bulk: true) do |t|
      t.column(:user_id, :bigint)
      t.column(:template_type, :integer, null: false, default: 0)
    end

    add_index(:inspection_templates, :user_id)
    add_foreign_key(:inspection_templates, :users)

    # Backfill existing records with system template type
    execute("UPDATE inspection_templates SET template_type = 0 WHERE user_id IS NULL")
  end

  def down
    remove_foreign_key(:inspection_templates, :users)
    remove_index(:inspection_templates, :user_id)

    change_table(:inspection_templates, bulk: true) do |t|
      t.remove(:template_type)
      t.remove(:user_id)
    end
  end
end
