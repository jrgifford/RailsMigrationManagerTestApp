require 'rails_helper'

RSpec.describe MigrationService, type: :service do
  let(:migration_files) do
    [
      "#{Rails.root}/db/migrate/20231201000000_create_users.rb",
      "#{Rails.root}/db/migrate/20231202000000_add_email_to_users.rb",
      "#{Rails.root}/db/migrate/20231203000000_create_posts.rb"
    ]
  end

  before do
    allow(Dir).to receive(:glob).with("#{Rails.root}/db/migrate/*.rb").and_return(migration_files)
    
    # Create test data directly in the database
    ActiveRecord::SchemaMigration.create!(version: '20231201000000')
    SkippedMigration.create!(version: '20231202000000', filename: '20231202000000_add_email_to_users.rb')
  end
  
  after do
    # Clean up test data
    ActiveRecord::SchemaMigration.delete_all
    SkippedMigration.delete_all
  end

  describe '.all_migrations' do
    it 'returns all migrations with correct status' do
      migrations = MigrationService.all_migrations
      
      expect(migrations.size).to eq(3)
      
      # Applied migration
      applied_migration = migrations.find { |m| m[:version] == '20231201000000' }
      expect(applied_migration[:status]).to eq('applied')
      expect(applied_migration[:filename]).to eq('20231201000000_create_users.rb')
      
      # Skipped migration
      skipped_migration = migrations.find { |m| m[:version] == '20231202000000' }
      expect(skipped_migration[:status]).to eq('skipped')
      expect(skipped_migration[:filename]).to eq('20231202000000_add_email_to_users.rb')
      
      # Pending migration
      pending_migration = migrations.find { |m| m[:version] == '20231203000000' }
      expect(pending_migration[:status]).to eq('pending')
      expect(pending_migration[:filename]).to eq('20231203000000_create_posts.rb')
    end
  end

  describe '.pending_migrations' do
    it 'returns only pending migrations' do
      pending = MigrationService.pending_migrations
      
      expect(pending.size).to eq(1)
      expect(pending.first[:version]).to eq('20231203000000')
      expect(pending.first[:status]).to eq('pending')
    end
  end

  describe '.run_migration' do
    it 'successfully runs a pending migration' do
      allow(ActiveRecord::Migration).to receive(:run).with(:up, migration_files[2], 20231203000000)
      
      result = MigrationService.run_migration('20231203000000')
      
      expect(result[:success]).to be true
      expect(result[:message]).to include('completed successfully')
    end

    it 'returns error for non-existent migration' do
      result = MigrationService.run_migration('99999999999999')
      
      expect(result[:success]).to be false
      expect(result[:error]).to eq('Migration not found')
    end

    it 'returns error for non-pending migration' do
      result = MigrationService.run_migration('20231201000000') # applied migration
      
      expect(result[:success]).to be false
      expect(result[:error]).to eq('Migration is not pending')
    end

    it 'handles migration execution errors' do
      allow(ActiveRecord::Migration).to receive(:run).and_raise(StandardError.new('Database error'))
      
      result = MigrationService.run_migration('20231203000000')
      
      expect(result[:success]).to be false
      expect(result[:error]).to include('Migration failed: Database error')
    end
  end

  describe '.skip_migration' do
    it 'successfully skips a pending migration' do
      result = MigrationService.skip_migration('20231203000000')
      
      expect(result[:success]).to be true
      expect(result[:message]).to include('marked as skipped')
      
      # Verify the skipped migration was created
      skipped = SkippedMigration.find_by(version: '20231203000000')
      expect(skipped).to be_present
      expect(skipped.filename).to eq('20231203000000_create_posts.rb')
    end

    it 'returns error for non-existent migration' do
      result = MigrationService.skip_migration('99999999999999')
      
      expect(result[:success]).to be false
      expect(result[:error]).to eq('Migration not found')
    end

    it 'returns error for non-pending migration' do
      result = MigrationService.skip_migration('20231201000000') # applied migration
      
      expect(result[:success]).to be false
      expect(result[:error]).to eq('Migration is not pending')
    end

    it 'handles database errors when creating skipped migration' do
      allow(SkippedMigration).to receive(:create!).and_raise(StandardError.new('Database error'))
      
      result = MigrationService.skip_migration('20231203000000')
      
      expect(result[:success]).to be false
      expect(result[:error]).to include('Failed to skip migration: Database error')
    end
  end
end
