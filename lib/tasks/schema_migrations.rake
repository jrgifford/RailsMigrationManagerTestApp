namespace :schema do
  desc "Generate migrations from a JSON schema file"
  task :generate_migrations, [:schema_file, :database] => :environment do |t, args|
    schema_file = args[:schema_file]
    database = args[:database] || 'primary'
    
    unless schema_file
      puts "❌ Error: Please provide a schema file path"
      puts "Usage: rails schema:generate_migrations[path/to/schema.json,database_name]"
      puts "Example: rails schema:generate_migrations[db/schema.json]"
      puts "Example: rails schema:generate_migrations[db/schema.json,saas]"
      exit 1
    end
    
    unless File.exist?(schema_file)
      puts "❌ Error: Schema file not found: #{schema_file}"
      exit 1
    end
    
    begin
      generator = SchemaMigrationGenerator.new(schema_file, database)
      results = generator.generate_all_migrations
      
      puts "\n🚀 Schema Migration Generator Results"
      puts "=" * 50
      puts "Database: #{database}"
      puts "Schema file: #{schema_file}"
      puts ""
      
      successful_migrations = results.select { |r| r[:success] }
      failed_migrations = results.select { |r| !r[:success] }
      
      if successful_migrations.any?
        puts "✅ Successfully generated #{successful_migrations.count} migration(s):"
        successful_migrations.each do |result|
          puts "   📄 #{result[:filename]} (#{result[:table_name]})"
          puts "      Path: #{result[:path]}"
        end
      end
      
      if failed_migrations.any?
        puts "\n❌ Failed to generate #{failed_migrations.count} migration(s):"
        failed_migrations.each do |result|
          puts "   ❌ #{result[:table_name]}: #{result[:error]}"
        end
      end
      
      puts "\n📋 Next steps:"
      puts "1. Review the generated migration files"
      puts "2. Run migrations using: rails db:migrate"
      puts "3. Or use the Migration Manager UI at /migrations"
      
    rescue => e
      puts "❌ Error generating migrations: #{e.message}"
      puts e.backtrace.first(5).join("\n") if ENV['DEBUG']
      exit 1
    end
  end
  
  desc "Preview migrations from a JSON schema file without creating files"
  task :preview, [:schema_file, :database] => :environment do |t, args|
    schema_file = args[:schema_file]
    database = args[:database] || 'primary'
    
    unless schema_file
      puts "❌ Error: Please provide a schema file path"
      puts "Usage: rails schema:preview[path/to/schema.json,database_name]"
      exit 1
    end
    
    unless File.exist?(schema_file)
      puts "❌ Error: Schema file not found: #{schema_file}"
      exit 1
    end
    
    begin
      generator = SchemaMigrationGenerator.new(schema_file, database)
      
      puts "\n🔍 Schema Migration Preview"
      puts "=" * 50
      puts "Database: #{database}"
      puts "Schema file: #{schema_file}"
      puts ""
      
      generator.schema_data['tables']&.each do |table_name, table_definition|
        puts "📄 Migration for table: #{table_name}"
        puts "-" * 30
        migration_content = generator.preview_migration(table_name, table_definition)
        puts migration_content
        puts ""
      end
      
    rescue => e
      puts "❌ Error previewing migrations: #{e.message}"
      exit 1
    end
  end
  
  desc "Generate an example schema file"
  task :example => :environment do
    example_schema = SchemaMigrationGenerator.example_schema
    filename = "db/example_schema.json"
    
    # Create db directory if it doesn't exist
    FileUtils.mkdir_p('db')
    
    File.write(filename, JSON.pretty_generate(example_schema))
    
    puts "✅ Example schema file created: #{filename}"
    puts ""
    puts "📋 To use this example:"
    puts "1. Edit #{filename} to match your desired schema"
    puts "2. Run: rails schema:preview[#{filename}] to preview migrations"
    puts "3. Run: rails schema:generate_migrations[#{filename}] to create migrations"
  end
  
  desc "Validate a schema file"
  task :validate, [:schema_file] => :environment do |t, args|
    schema_file = args[:schema_file]
    
    unless schema_file
      puts "❌ Error: Please provide a schema file path"
      puts "Usage: rails schema:validate[path/to/schema.json]"
      exit 1
    end
    
    unless File.exist?(schema_file)
      puts "❌ Error: Schema file not found: #{schema_file}"
      exit 1
    end
    
    begin
      generator = SchemaMigrationGenerator.new(schema_file)
      schema = generator.schema_data
      
      puts "✅ Schema file is valid JSON"
      puts ""
      puts "📊 Schema Summary:"
      puts "Version: #{schema['version'] || 'not specified'}"
      puts "Database: #{schema['database'] || 'not specified'}"
      puts "Tables: #{schema['tables']&.keys&.count || 0}"
      
      if schema['tables']
        schema['tables'].each do |table_name, table_def|
          columns_count = table_def['columns']&.count || 0
          indexes_count = table_def['indexes']&.count || 0
          fk_count = table_def['foreign_keys']&.count || 0
          
          puts "  📄 #{table_name}: #{columns_count} columns, #{indexes_count} indexes, #{fk_count} foreign keys"
        end
      end
      
    rescue => e
      puts "❌ Schema validation failed: #{e.message}"
      exit 1
    end
  end
end
