class CreateCommentsAndUpdatePosts < ActiveRecord::Migration[7.1]
  def change
    create_table :comments do |t|
      t.text :content, null: false
      t.references :post, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :parent, null: true, foreign_key: { to_table: :comments }
      t.boolean :approved, default: false
      t.string :ip_address
      t.string :user_agent

      t.timestamps
    end

    add_index :comments, [:post_id, :approved]
    add_index :comments, :created_at

    add_column :posts, :comments_count, :integer, default: 0
    add_column :posts, :featured, :boolean, default: false
    add_column :posts, :tags, :text

    add_index :posts, :featured

    reversible do |dir|
      dir.up do
        execute "UPDATE posts SET comments_count = 0 WHERE comments_count IS NULL"
      end
    end
  end
end
