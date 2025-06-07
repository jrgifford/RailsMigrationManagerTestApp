class SchemaMigrationGenerator
  attr_reader :schema_data, :database
  
  def initialize(schema_file_path, database = 'primary')
    @schema_data = read_schema_file(schema_file_path)
    @database = database
  end
  
  def generate_all_migrations
    results = []
    
    schema_data['tables']&.each do |table_name, table_definition|
      result = generate_table_migration(table_name, table_definition)
      results << result
    end
    
    results
  end
  
  def generate_table_migration(table_name, table_definition)
    timestamp = generate_timestamp
    migration_name = "create_#{table_name.pluralize}"
    filename = "#{timestamp}_#{migration_name}.rb"
    
    migration_content = build_migration_content(migration_name.camelize, table_name, table_definition)
    
    # Determine the correct migration path based on database
    migration_path = get_migration_path
    full_path = File.join(Rails.root, migration_path, filename)
    
    begin
      # Create the migration directory if it doesn't exist
      FileUtils.mkdir_p(File.dirname(full_path))
      
      # Write the migration file
      File.write(full_path, migration_content)
      
      {
        success: true,
        table_name: table_name,
        filename: filename,
        path: full_path,
        migration_name: migration_name,
        database: database
      }
    rescue => e
      {
        success: false,
        table_name: table_name,
        error: "Failed to create migration: #{e.message}",
        database: database
      }
    end
  end
  
  def preview_migration(table_name, table_definition)
    migration_name = "create_#{table_name.pluralize}"
    build_migration_content(migration_name.camelize, table_name, table_definition)
  end
  
  def self.example_schema
    {
      "version" => "1.0",
      "database" => "primary",
      "tables" => {
        "users" => {
          "columns" => {
            "id" => { "type" => "primary_key" },
            "email" => { "type" => "string", "null" => false, "index" => true },
            "name" => { "type" => "string", "null" => false },
            "age" => { "type" => "integer", "null" => true },
            "active" => { "type" => "boolean", "default" => true },
            "created_at" => { "type" => "datetime", "null" => false },
            "updated_at" => { "type" => "datetime", "null" => false }
          },
          "indexes" => [
            { "columns" => ["email"], "unique" => true },
            { "columns" => ["name", "email"], "name" => "idx_users_name_email" }
          ],
          "foreign_keys" => []
        },
        "posts" => {
          "columns" => {
            "id" => { "type" => "primary_key" },
            "title" => { "type" => "string", "null" => false },
            "content" => { "type" => "text" },
            "user_id" => { "type" => "bigint", "null" => false },
            "published_at" => { "type" => "datetime" },
            "created_at" => { "type" => "datetime", "null" => false },
            "updated_at" => { "type" => "datetime", "null" => false }
          },
          "indexes" => [
            { "columns" => ["user_id"] },
            { "columns" => ["published_at"] }
          ],
          "foreign_keys" => [
            { "column" => "user_id", "references" => "users", "on_delete" => "cascade" }
          ]
        }
      }
    }
  end
  
  private
  
  def read_schema_file(file_path)
    unless File.exist?(file_path)
      raise "Schema file not found: #{file_path}"
    end
    
    begin
      JSON.parse(File.read(file_path))
    rescue JSON::ParserError => e
      raise "Invalid JSON in schema file: #{e.message}"
    end
  end
  
  def get_migration_path
    config = MigrationService.database_configs[database]
    return 'db/migrate' unless config
    config[:path]
  end
  
  def generate_timestamp
    Time.current.strftime('%Y%m%d%H%M%S')
  end
  
  def build_migration_content(class_name, table_name, table_definition)
    columns = table_definition['columns'] || {}
    indexes = table_definition['indexes'] || []
    foreign_keys = table_definition['foreign_keys'] || []
    
    migration_code = []
    migration_code << "class #{class_name} < ActiveRecord::Migration[7.1]"
    migration_code << "  def change"
    migration_code << "    create_table :#{table_name} do |t|"
    
    # Add columns (skip id if it's explicitly defined as primary_key)
    columns.each do |column_name, column_def|
      next if column_name == 'id' && column_def['type'] == 'primary_key'
      migration_code << format_column_definition(column_name, column_def)
    end
    
    migration_code << "    end"
    migration_code << ""
    
    # Add indexes
    indexes.each do |index_def|
      migration_code << format_index_definition(table_name, index_def)
    end
    
    # Add foreign keys
    foreign_keys.each do |fk_def|
      migration_code << format_foreign_key_definition(table_name, fk_def)
    end
    
    migration_code << "  end"
    migration_code << "end"
    
    migration_code.join("\n")
  end
  
  def format_column_definition(column_name, column_def)
    line_parts = ["      t.#{column_def['type']} :#{column_name}"]
    
    # Add options
    options = []
    options << "null: #{column_def['null']}" unless column_def['null'].nil?
    options << "default: #{format_default_value(column_def['default'])}" if column_def['default']
    options << "limit: #{column_def['limit']}" if column_def['limit']
    options << "precision: #{column_def['precision']}" if column_def['precision']
    options << "scale: #{column_def['scale']}" if column_def['scale']
    
    if options.any?
      line_parts << ", #{options.join(', ')}"
    end
    
    line_parts.join('')
  end
  
  def format_default_value(value)
    case value
    when String
      "'#{value}'"
    when TrueClass, FalseClass, Numeric
      value
    else
      "'#{value}'"
    end
  end
  
  def format_index_definition(table_name, index_def)
    columns = index_def['columns']
    options = []
    
    if index_def['unique']
      options << "unique: true"
    end
    
    if index_def['name']
      options << "name: '#{index_def['name']}'"
    end
    
    options_str = options.any? ? ", #{options.join(', ')}" : ""
    
    if columns.is_a?(Array) && columns.length > 1
      "    add_index :#{table_name}, #{columns.inspect}#{options_str}"
    else
      column = columns.is_a?(Array) ? columns.first : columns
      "    add_index :#{table_name}, :#{column}#{options_str}"
    end
  end
  
  def format_foreign_key_definition(table_name, fk_def)
    options = []
    
    if fk_def['on_delete']
      options << "on_delete: :#{fk_def['on_delete']}"
    end
    
    if fk_def['on_update']
      options << "on_update: :#{fk_def['on_update']}"
    end
    
    options_str = options.any? ? ", #{options.join(', ')}" : ""
    
    "    add_foreign_key :#{table_name}, :#{fk_def['references']}, column: :#{fk_def['column']}#{options_str}"
  end
end
