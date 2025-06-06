class SocialNetworkRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to database: { writing: :social_network, reading: :social_network }
end
