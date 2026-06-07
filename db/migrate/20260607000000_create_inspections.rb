class CreateInspections < ActiveRecord::Migration[8.2]
  def change
    create_table(:inspections) do |t|
      t.references(:user, null: false, foreign_key: true)
      t.references(:inspection_template, null: false, foreign_key: true)
      t.text(:property_address)
      t.string(:client_name)
      t.string(:client_email)
      t.text(:signature_data)
      t.integer(:status)
      t.string(:pdf_url)
      t.datetime(:completed_at)

      t.timestamps
    end

    add_index(:inspections, :status)
  end
end
