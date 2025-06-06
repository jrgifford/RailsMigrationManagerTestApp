class CreateSkippedMigrations < ActiveRecord::Migration[7.1]
  def change
    create_table :skipped_migrations do |t|
      t.string :version
      t.string :filename
      t.datetime :skipped_at

      t.timestamps
    end
  end
end
