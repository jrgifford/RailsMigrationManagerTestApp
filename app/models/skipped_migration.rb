class SkippedMigration < ApplicationRecord
  validates :version, presence: true, uniqueness: true
  validates :filename, presence: true
  
  scope :by_version, -> { order(:version) }
  
  def self.skipped_versions
    pluck(:version)
  end
end
