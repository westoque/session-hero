class AddDemoExpiresAtToEventsAndUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :events, :demo_expires_at, :datetime
    add_column :users,  :demo_expires_at, :datetime
    add_index  :events, :demo_expires_at
    add_index  :users,  :demo_expires_at
  end
end
