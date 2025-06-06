class SocialNetworkProfile < SocialNetworkRecord
  validates :username, presence: true, uniqueness: true
  validates :display_name, presence: true
  validates :bio, length: { maximum: 500 }
end
