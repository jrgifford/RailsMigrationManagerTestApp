class MigrationService
  def self.all_migrations
    migration_files = Dir.glob("#{Rails.root}/db/migrate/*.rb").sort
    applied_versions = ActiveRecord::Base.connection.select_values("SELECT version FROM schema_migrations")
    skipped_versions = SkippedMigration.skipped_versions
    
    migration_files.map do |file|
      filename = File.basename(file)
      version = filename.split('_').first
      
      status = if applied_versions.include?(version)
                 'applied'
               elsif skipped_versions.include?(version)
                 'skipped'
               else
                 'pending'
               end
      
      {
        version: version,
        filename: filename,
        status: status,
        full_path: file
      }
    end
  end
  
  def self.pending_migrations
    all_migrations.select { |migration| migration[:status] == 'pending' }
  end
  
  def self.run_migration(version)
    migration = find_migration(version)
    return { success: false, error: 'Migration not found' } unless migration
    return { success: false, error: 'Migration is not pending' } unless migration[:status] == 'pending'
    
    begin
      ActiveRecord::Migration.run(:up, migration[:full_path], version.to_i)
      { success: true, message: "Migration #{version} completed successfully" }
    rescue => e
      { success: false, error: "Migration failed: #{e.message}" }
    end
  end
  
  def self.skip_migration(version)
    migration = find_migration(version)
    return { success: false, error: 'Migration not found' } unless migration
    return { success: false, error: 'Migration is not pending' } unless migration[:status] == 'pending'
    
    begin
      SkippedMigration.create!(
        version: version,
        filename: migration[:filename],
        skipped_at: Time.current
      )
      { success: true, message: "Migration #{version} marked as skipped" }
    rescue => e
      { success: false, error: "Failed to skip migration: #{e.message}" }
    end
  end
  
  private
  
  def self.find_migration(version)
    all_migrations.find { |migration| migration[:version] == version }
  end
end
