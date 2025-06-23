# Ensure ActiveRecord::SchemaMigration responds to pluck for compatibility and stubbing in tests

ActiveRecord::SchemaMigration.class_eval do
  def self.pluck(*args)
    ActiveRecord::Base.connection.execute("SELECT #{args.join(', ')} FROM schema_migrations").map { |row| row.values.first }
  end
end
