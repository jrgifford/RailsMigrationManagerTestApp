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
      # Load the migration file to get the class
      require migration[:full_path]
      
      # Extract migration class name from filename
      class_name = migration[:filename].gsub(/^\d+_/, '').gsub(/\.rb$/, '').camelize
      migration_class = class_name.constantize
      
      # Run the migration
      migration_instance = migration_class.new
      migration_instance.migrate(:up)
      
      # Add to schema_migrations table
      ActiveRecord::Base.connection.execute("INSERT INTO schema_migrations (version) VALUES ('#{version}')")
      
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
  
  def self.unskip_migration(version)
    migration = find_migration(version)
    return { success: false, error: 'Migration not found' } unless migration
    return { success: false, error: 'Migration is not skipped' } unless migration[:status] == 'skipped'
    
    begin
      skipped_migration = SkippedMigration.find_by(version: version)
      skipped_migration&.destroy!
      { success: true, message: "Migration #{version} unskipped and is now pending" }
    rescue => e
      { success: false, error: "Failed to unskip migration: #{e.message}" }
    end
  end
  
  def self.find_migration_by_version(version)
    find_migration(version)
  end
  
  def self.read_migration_content(version)
    migration = find_migration(version)
    return nil unless migration
    
    # Security: Only read files from our known migration list
    # This prevents directory traversal and arbitrary file reads
    file_path = migration[:full_path]
    
    # Double-check that the path is within our migrations directory
    migrations_dir = File.join(Rails.root, 'db', 'migrate')
    unless file_path.start_with?(migrations_dir)
      Rails.logger.warn "Attempted to read file outside migrations directory: #{file_path}"
      return nil
    end
    
    # Ensure the file exists and is readable
    unless File.exist?(file_path) && File.readable?(file_path)
      Rails.logger.warn "Migration file not found or not readable: #{file_path}"
      return nil
    end
    
    begin
      File.read(file_path)
    rescue => e
      Rails.logger.error "Error reading migration file #{file_path}: #{e.message}"
      nil
    end
  end
  
  private
  
  def self.find_migration(version)
    all_migrations.find { |migration| migration[:version] == version }
  end
end
