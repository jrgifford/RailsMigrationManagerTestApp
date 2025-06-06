class RunMigrationJob < ApplicationJob
  queue_as :default

  def perform(migration_id)
    MigrationService.run_migration(migration_id)
  end
end
