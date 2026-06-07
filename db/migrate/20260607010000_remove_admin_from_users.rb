class RemoveAdminFromUsers < ActiveRecord::Migration[8.2]
  def change
    remove_column(:users, :admin, :boolean, default: false, null: false)
  end
end
