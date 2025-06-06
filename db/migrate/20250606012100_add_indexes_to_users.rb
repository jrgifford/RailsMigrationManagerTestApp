class AddIndexesToUsers < ActiveRecord::Migration[7.1]
  def change
    add_index :users, :email, unique: true
    add_index :users, :name
    add_column :users, :role, :string, default: 'user'
    add_column :users, :active, :boolean, default: true
    
    change_column_null :users, :email, false
  end
end
