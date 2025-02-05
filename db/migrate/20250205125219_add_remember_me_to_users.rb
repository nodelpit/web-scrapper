class AddRememberMeToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :remember_token, :string
    add_index :users, :remember_token
    add_column :users, :remember_created_at, :datetime
  end
end
