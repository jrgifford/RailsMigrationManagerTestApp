# Ensure ActiveRecord::SchemaMigration responds to pluck for compatibility and stubbing in tests
ActiveRecord::SchemaMigration.class_eval do
  def self.pluck(*args)
    all.pluck(*args)
  end
end
