class RemoveSubscribedFromUsers < ActiveRecord::Migration[8.2]
  def change
    remove_column :users, :subscribed, :boolean
  end
end
