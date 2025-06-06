class CreatePosts < ActiveRecord::Migration[7.1]
  def change
    create_table :posts do |t|
      t.string :title, null: false
      t.text :content
      t.boolean :published, default: false
      t.references :user, null: false, foreign_key: true
      t.integer :view_count, default: 0
      t.datetime :published_at

      t.timestamps
    end

    add_index :posts, :published
    add_index :posts, :published_at
    add_index :posts, [:user_id, :published]
  end
end
