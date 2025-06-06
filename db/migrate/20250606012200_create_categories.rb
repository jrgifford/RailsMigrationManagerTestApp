class CreateCategories < ActiveRecord::Migration[7.1]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.string :color, default: '#6B7280'
      t.integer :posts_count, default: 0

      t.timestamps
    end

    add_index :categories, :slug, unique: true
    add_index :categories, :name

    create_join_table :posts, :categories do |t|
      t.index :post_id
      t.index :category_id
      t.index [:post_id, :category_id], unique: true
    end
  end
end
