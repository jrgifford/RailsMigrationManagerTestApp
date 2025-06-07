# Configure multiple databases for Rails
# Rails.application.configure do
#   config.active_record.database_selector = { delay: 2.seconds }
#   config.active_record.database_resolver = ActiveRecord::Middleware::DatabaseSelector::Resolver
#   config.active_record.database_resolver_context = ActiveRecord::Middleware::DatabaseSelector::Resolver::Session
# end

# Set up migration paths for additional databases
ActiveRecord::Tasks::DatabaseTasks.migrations_paths = {
  'primary' => ['db/migrate'],
  'saas' => ['db/saas_migrate'],
  'social_network' => ['db/social_network_migrate']
}
