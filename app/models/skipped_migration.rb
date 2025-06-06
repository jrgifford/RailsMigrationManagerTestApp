class SkippedMigration < ApplicationRecord
  validates :version, presence: true, uniqueness: { scope: :database }
  validates :filename, presence: true
  validates :database, presence: true
  
  scope :by_version, -> { order(:version) }
  scope :for_database, ->(db) { where(database: db) }
  
  def self.skipped_versions
    pluck(:version)
  end
end
