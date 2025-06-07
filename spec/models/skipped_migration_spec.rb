require 'rails_helper'

RSpec.describe SkippedMigration, type: :model do
  subject { build(:skipped_migration) }

  it 'is valid with valid attributes' do
    expect(subject).to be_valid
  end

  context 'validations' do
    it 'requires a version' do
      subject.version = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:version]).to include("can't be blank")
    end

    it 'requires a filename' do
      subject.filename = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:filename]).to include("can't be blank")
    end

    it 'requires skipped_at' do
      subject.skipped_at = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:skipped_at]).to include("can't be blank")
    end

    it 'requires a reason' do
      subject.reason = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:reason]).to include("can't be blank")
    end

    it 'enforces uniqueness of version' do
      create(:skipped_migration, version: subject.version)
      expect(subject).not_to be_valid
      expect(subject.errors[:version]).to include("has already been taken")
    end
  end
end
