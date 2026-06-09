class CreateReportTemplates < ActiveRecord::Migration[8.2]
  def change
    create_table(:report_templates) do |t|
      t.references(:country, null: false, foreign_key: true)
      t.string(:locale, null: false)
      t.text(:header_text)
      t.text(:footer_text)
      t.text(:legal_disclaimer)

      t.timestamps
    end

    add_index(:report_templates, [:country_id, :locale], unique: true)
  end
end
