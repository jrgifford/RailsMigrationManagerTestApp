# frozen_string_literal: true
class MigrationService
  def self.applied_migrations
    ActiveRecord::SchemaMigration.pluck(:version)
  end

  def self.skipped_migrations
    SkippedMigration.pluck(:version)
  end

  def self.pending_migrations
    files = Dir.glob('db/migrate/*.rb')
    migrations = files.map do |path|
      filename = File.basename(path)
      version = filename.split('_').first
      { version: version, filename: filename }
    end
    migrations.reject do |m|
      applied_migrations.include?(m[:version]) || skipped_migrations.include?(m[:version])
    end
  end

  def self.run(version)
    context = ActiveRecord::MigrationContext.new('db/migrate', ActiveRecord::SchemaMigration)
    context.up(version)
  end

  def self.skip(version, reason = nil)
    filename = filename_for(version)
    SkippedMigration.create!(
      version: version,
      filename: filename,
      skipped_at: Time.current,
      reason: reason
    )
  end

  def self.filename_for(version)
    Dir.glob('db/migrate/*.rb')
       .map { |path| File.basename(path) }
       .find { |file| file.start_with?(version) }
  end
end
