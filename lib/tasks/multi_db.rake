namespace :db do
  namespace :migrate do
    desc "Run migrations for SaaS database"
    task :saas => :environment do
      ActiveRecord::Base.establish_connection(:saas)
      ActiveRecord::MigrationContext.new("db/saas_migrate", ActiveRecord::SchemaMigration).migrate
      Rake::Task["db:schema:dump:saas"].invoke
    end

    desc "Run migrations for Social Network database"
    task :social_network => :environment do
      ActiveRecord::Base.establish_connection(:social_network)
      ActiveRecord::MigrationContext.new("db/social_network_migrate", ActiveRecord::SchemaMigration).migrate
      Rake::Task["db:schema:dump:social_network"].invoke
    end
  end

  namespace :schema do
    namespace :dump do
      desc "Dump schema for SaaS database"
      task :saas => :environment do
        ActiveRecord::Base.establish_connection(:saas)
        File.open("db/saas_schema.rb", "w") do |file|
          ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
        end
      end

      desc "Dump schema for Social Network database"
      task :social_network => :environment do
        ActiveRecord::Base.establish_connection(:social_network)
        File.open("db/social_network_schema.rb", "w") do |file|
          ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
        end
      end
    end
  end
end
