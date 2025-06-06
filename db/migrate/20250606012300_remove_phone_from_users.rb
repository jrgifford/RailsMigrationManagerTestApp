class RemovePhoneFromUsers < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :phone, :string
    remove_index :posts, name: 'index_posts_on_published_at'
    
    add_column :users, :bio, :text
    add_column :users, :avatar_url, :string
  end

  def down
    add_column :users, :phone, :string
    add_index :posts, :published_at
    
    remove_column :users, :bio
    remove_column :users, :avatar_url
  end
end
