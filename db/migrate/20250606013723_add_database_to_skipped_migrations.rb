class AddDatabaseToSkippedMigrations < ActiveRecord::Migration[7.1]
  def change
    add_column :skipped_migrations, :database, :string, default: 'primary', null: false
    
    # Update existing records to use 'primary' database
    reversible do |dir|
      dir.up do
        execute "UPDATE skipped_migrations SET database = 'primary' WHERE database IS NULL"
      end
    end
    
    # Add index for performance
    add_index :skipped_migrations, [:database, :version], unique: true
    
    # Remove the old unique index on version only
    remove_index :skipped_migrations, :version if index_exists?(:skipped_migrations, :version)
  end
end
