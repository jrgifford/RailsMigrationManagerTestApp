require 'rails_helper'

RSpec.describe SkippedMigration, type: :model do
  describe 'validations' do
    it 'requires version to be present' do
      migration = SkippedMigration.new(filename: 'test_migration.rb')
      expect(migration).not_to be_valid
      expect(migration.errors[:version]).to include("can't be blank")
    end

    it 'requires filename to be present' do
      migration = SkippedMigration.new(version: '20231201000000')
      expect(migration).not_to be_valid
      expect(migration.errors[:filename]).to include("can't be blank")
    end

    it 'requires version to be unique' do
      SkippedMigration.create!(version: '20231201000000', filename: 'test_migration.rb')
      duplicate = SkippedMigration.new(version: '20231201000000', filename: 'another_migration.rb')
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:version]).to include("has already been taken")
    end

    it 'is valid with version and filename' do
      migration = SkippedMigration.new(version: '20231201000000', filename: 'test_migration.rb')
      expect(migration).to be_valid
    end
  end

  describe 'scopes' do
    it 'orders by version' do
      migration2 = SkippedMigration.create!(version: '20231202000000', filename: 'second_migration.rb')
      migration1 = SkippedMigration.create!(version: '20231201000000', filename: 'first_migration.rb')
      
      expect(SkippedMigration.by_version).to eq([migration1, migration2])
    end
  end

  describe '.skipped_versions' do
    it 'returns array of skipped versions' do
      SkippedMigration.create!(version: '20231201000000', filename: 'first_migration.rb')
      SkippedMigration.create!(version: '20231202000000', filename: 'second_migration.rb')
      
      expect(SkippedMigration.skipped_versions).to contain_exactly('20231201000000', '20231202000000')
    end

    it 'returns empty array when no skipped migrations' do
      expect(SkippedMigration.skipped_versions).to eq([])
    end
  end
end
