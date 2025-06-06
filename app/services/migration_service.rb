class MigrationService
  def self.database_configs
    @database_configs ||= begin
      # Get all database configurations for the current environment
      env_configs = ActiveRecord::Base.configurations.configurations.select { |config| config.env_name == Rails.env }
      
      # Build our configuration hash, filtering out role-specific configs and duplicates
      database_names = env_configs.map(&:name).uniq
      
      database_names.each_with_object({}) do |database_name, hash|
        # Map database names to their migration paths and connection classes
        case database_name
        when 'primary'
          hash[database_name] = {
            path: 'db/migrate',
            connection_class_name: 'ActiveRecord::Base',
            skipped_migration_class: SkippedMigration
          }
        when 'saas'
          hash[database_name] = {
            path: 'db/saas_migrate',
            connection_class_name: 'SaasRecord',
            skipped_migration_class: SkippedMigration # We'll use the primary database for tracking skipped migrations for now
          }
        when 'social_network'
          hash[database_name] = {
            path: 'db/social_network_migrate',
            connection_class_name: 'SocialNetworkRecord',
            skipped_migration_class: SkippedMigration # We'll use the primary database for tracking skipped migrations for now
          }
        end
      end.freeze
    end
  end

  def self.enabled_databases
    database_configs.keys.select do |database|
      database_accessible?(database)
    end
  end

  def self.all_migrations(database = 'primary')
    config = database_configs[database]
    return [] unless config

    migration_files = Dir.glob("#{Rails.root}/#{config[:path]}/*.rb").sort
    applied_versions = get_applied_versions(database)
    skipped_versions = get_skipped_versions(database)
    
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
        full_path: file,
        database: database
      }
    end
  end

  def self.all_databases_summary
    enabled_databases.map do |database|
      migrations = all_migrations(database)
      {
        database: database,
        total_count: migrations.count,
        pending_count: migrations.count { |m| m[:status] == 'pending' },
        applied_count: migrations.count { |m| m[:status] == 'applied' },
        skipped_count: migrations.count { |m| m[:status] == 'skipped' }
      }
    end
  end
  
  def self.pending_migrations(database = 'primary')
    all_migrations(database).select { |migration| migration[:status] == 'pending' }
  end
  
  def self.run_migration(version, database = 'primary')
    migration = find_migration(version, database)
    return { success: false, error: 'Migration not found' } unless migration
    return { success: false, error: 'Migration is not pending' } unless migration[:status] == 'pending'
    
    config = database_configs[database]
    return { success: false, error: 'Invalid database' } unless config
    
    begin
      # Load the migration file to get the class
      require migration[:full_path]
      
      # Extract migration class name from filename
      class_name = migration[:filename].gsub(/^\d+_/, '').gsub(/\.rb$/, '').camelize
      migration_class = class_name.constantize
      
      # Get the connection class
      connection_class = get_connection_class(database)
      return { success: false, error: "Connection class not available for #{database}" } unless connection_class
      
      # Run the migration on the correct database connection
      connection_class.connection_pool.with_connection do |connection|
        migration_instance = migration_class.new
        migration_instance.instance_variable_set(:@connection, connection)
        migration_instance.migrate(:up)
        
        # Add to schema_migrations table for this database
        connection.execute("INSERT INTO schema_migrations (version) VALUES ('#{version}')")
      end
      
      { success: true, message: "Migration #{version} completed successfully for #{database} database" }
    rescue => e
      { success: false, error: "Migration failed: #{e.message}" }
    end
  end
  
  def self.skip_migration(version, database = 'primary')
    migration = find_migration(version, database)
    return { success: false, error: 'Migration not found' } unless migration
    return { success: false, error: 'Migration is not pending' } unless migration[:status] == 'pending'
    
    begin
      SkippedMigration.create!(
        version: version,
        filename: migration[:filename],
        database: database,
        skipped_at: Time.current
      )
      { success: true, message: "Migration #{version} marked as skipped for #{database} database" }
    rescue => e
      { success: false, error: "Failed to skip migration: #{e.message}" }
    end
  end
  
  def self.unskip_migration(version, database = 'primary')
    migration = find_migration(version, database)
    return { success: false, error: 'Migration not found' } unless migration
    return { success: false, error: 'Migration is not skipped' } unless migration[:status] == 'skipped'
    
    begin
      skipped_migration = SkippedMigration.find_by(version: version, database: database)
      skipped_migration&.destroy!
      { success: true, message: "Migration #{version} unskipped and is now pending for #{database} database" }
    rescue => e
      { success: false, error: "Failed to unskip migration: #{e.message}" }
    end
  end
  
  def self.find_migration_by_version(version, database = 'primary')
    find_migration(version, database)
  end
  
  def self.read_migration_content(version, database = 'primary')
    migration = find_migration(version, database)
    return nil unless migration
    
    config = database_configs[database]
    return nil unless config
    
    # Security: Only read files from our known migration list
    # This prevents directory traversal and arbitrary file reads
    file_path = migration[:full_path]
    
    # Double-check that the path is within our migrations directory for this database
    migrations_dir = File.join(Rails.root, config[:path])
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
  
  def self.find_migration(version, database = 'primary')
    all_migrations(database).find { |migration| migration[:version] == version }
  end

  def self.get_applied_versions(database)
    config = database_configs[database]
    return [] unless config

    # Use the connection class for all databases, including primary
    begin
      connection_class = get_connection_class(database)
      return [] unless connection_class
      
      # Try to establish a connection to verify the database is configured
      connection_class.connection_pool.with_connection do |connection|
        if connection.table_exists?('schema_migrations')
          connection.select_values("SELECT version FROM schema_migrations")
        else
          []
        end
      end
    rescue ActiveRecord::AdapterNotSpecified, ActiveRecord::ConnectionNotEstablished => e
      Rails.logger.warn "Database #{database} is not properly configured: #{e.message}"
      []
    rescue => e
      Rails.logger.error "Error fetching applied versions for #{database}: #{e.message}"
      []
    end
  end

  def self.get_skipped_versions(database)
    # For now, we'll store all skipped migrations in the primary database
    # but track which database they belong to
    SkippedMigration.where(database: database).pluck(:version)
  rescue => e
    Rails.logger.error "Error fetching skipped versions for #{database}: #{e.message}"
    []
  end

  def self.database_accessible?(database)
    config = database_configs[database]
    return false unless config

    # Primary database is always accessible if we're running Rails
    return true if database == 'primary'

    # For other databases, try to connect
    begin
      connection_class = get_connection_class(database)
      return false unless connection_class
      
      connection_class.connection_pool.with_connection do |connection|
        connection.active?
      end
      true
    rescue ActiveRecord::AdapterNotSpecified, ActiveRecord::ConnectionNotEstablished => e
      Rails.logger.debug "Database #{database} is not accessible: #{e.message}"
      false
    rescue => e
      Rails.logger.warn "Error checking database #{database} accessibility: #{e.message}"
      false
    end
  end

  def self.get_connection_class(database)
    config = database_configs[database]
    return nil unless config

    # Return ActiveRecord::Base for primary database
    return ActiveRecord::Base if database == 'primary'

    # For other databases, try to constantize the class name safely
    begin
      config[:connection_class_name].constantize
    rescue NameError => e
      Rails.logger.warn "Connection class #{config[:connection_class_name]} not found for database #{database}: #{e.message}"
      nil
    rescue => e
      Rails.logger.error "Error loading connection class for database #{database}: #{e.message}"
      nil
    end
  end
end
