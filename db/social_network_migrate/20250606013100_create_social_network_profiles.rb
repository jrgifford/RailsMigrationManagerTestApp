class CreateSocialNetworkProfiles < ActiveRecord::Migration[7.1]
  def change
    create_table :social_network_profiles do |t|
      t.string :username
      t.string :display_name
      t.text :bio
      t.string :avatar_url

      t.timestamps
    end

    add_index :social_network_profiles, :username, unique: true
  end
end
