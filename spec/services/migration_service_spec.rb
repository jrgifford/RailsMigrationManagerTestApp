require 'rails_helper'

RSpec.describe MigrationService do
  describe '.applied_migrations' do
    it 'returns all applied migration versions' do
      allow(ActiveRecord::SchemaMigration).to receive(:pluck).with(:version).and_return(['202001', '202002'])
      expect(MigrationService.applied_migrations).to match_array(['202001', '202002'])
    end
  end

  describe '.skipped_migrations' do
    it 'returns all skipped migration versions' do
      allow(SkippedMigration).to receive(:pluck).with(:version).and_return(['202003'])
      expect(MigrationService.skipped_migrations).to match_array(['202003'])
    end
  end

  describe '.pending_migrations' do
    it 'returns migrations not applied or skipped' do
      files = [
        'db/migrate/202001_create_users.rb',
        'db/migrate/202002_add_index.rb',
        'db/migrate/202003_update_posts.rb'
      ]
      allow(Dir).to receive(:glob).with('db/migrate/*.rb').and_return(files)
      allow(MigrationService).to receive(:applied_migrations).and_return(['202001'])
      allow(MigrationService).to receive(:skipped_migrations).and_return(['202002'])

      pending = MigrationService.pending_migrations
      expect(pending).to eq([
        { version: '202003', filename: '202003_update_posts.rb' }
      ])
    end
  end

  describe '.run' do
    it 'runs the migration for the given version' do
      context = instance_double('ActiveRecord::MigrationContext')
      allow(ActiveRecord::MigrationContext).to receive(:new)
        .with('db/migrate', ActiveRecord::SchemaMigration)
        .and_return(context)
      expect(context).to receive(:up).with('202001')

      MigrationService.run('202001')
    end
  end

  describe '.skip' do
    it 'creates a skipped migration record' do
      filename = '202004_add_comments.rb'
      allow(MigrationService).to receive(:filename_for).with('202004').and_return(filename)
      expect(SkippedMigration).to receive(:create!).with(
        version: '202004',
        filename: filename,
        skipped_at: an_instance_of(ActiveSupport::TimeWithZone),
        reason: nil
      )

      MigrationService.skip('202004')
    end
  end
end
