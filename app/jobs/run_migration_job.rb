class RunMigrationJob < ApplicationJob
  queue_as :default

  def perform(migration_id, database = 'primary')
    MigrationService.run_migration(migration_id, database)
  end
end
