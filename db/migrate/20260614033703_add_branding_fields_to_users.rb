# frozen_string_literal: true

class AddBrandingFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    change_table(:users, bulk: true) do |t|
      t.string(:license_number)
      t.string(:certification_number)
    end
  end
end
