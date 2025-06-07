class SkippedMigration < ApplicationRecord
  validates :version, presence: true, uniqueness: true
  validates :filename, presence: true
  validates :skipped_at, presence: true
  validates :reason, presence: true
end
