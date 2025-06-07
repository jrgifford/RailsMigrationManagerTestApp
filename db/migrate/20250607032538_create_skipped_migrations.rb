class CreateSkippedMigrations < ActiveRecord::Migration[7.1]
  def change
    create_table :skipped_migrations do |t|
      t.string :version
      t.string :filename
      t.datetime :skipped_at, null: false
      t.string :reason, null: false

      t.timestamps
    end

    add_index :skipped_migrations, :version, unique: true
  end
end
