# Multi-Database Setup

This Rails application is configured to use multiple databases with Rails multi-database support.

## Database Configuration

The application uses three SQLite3 databases:

1. **Primary Database** (`primary`) - Main application database
2. **SaaS Database** (`saas`) - For SaaS-related functionality
3. **Social Network Database** (`social_network`) - For social network features

## Database Files

- Primary: `storage/development.sqlite3`
- SaaS: `storage/development_saas.sqlite3`
- Social Network: `storage/development_social_network.sqlite3`

## Model Base Classes

### For Primary Database
```ruby
class MyModel < ApplicationRecord
  # Uses primary database by default
end
```

### For SaaS Database
```ruby
class SaasModel < SaasRecord
  # Uses saas database
end
```

### For Social Network Database
```ruby
class SocialNetworkModel < SocialNetworkRecord
  # Uses social_network database
end
```

## Migration Directories

- Primary: `db/migrate/`
- SaaS: `db/saas_migrate/`
- Social Network: `db/social_network_migrate/`

## Running Migrations

### All Databases
```bash
bin/rails db:create  # Creates all databases
bin/rails db:migrate # Migrates primary database
```

### Individual Databases
```bash
# SaaS database
bin/rails db:migrate:saas

# Social Network database
bin/rails db:migrate:social_network
```

## Example Models

### SaasCustomer
```ruby
class SaasCustomer < SaasRecord
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :plan, presence: true, inclusion: { in: ['basic', 'premium', 'enterprise'] }
end
```

### SocialNetworkProfile
```ruby
class SocialNetworkProfile < SocialNetworkRecord
  validates :username, presence: true, uniqueness: true
  validates :display_name, presence: true
  validates :bio, length: { maximum: 500 }
end
```

## Usage Examples

```ruby
# Create a SaaS customer
customer = SaasCustomer.create!(
  name: 'John Doe',
  email: 'john@example.com',
  plan: 'premium'
)

# Create a social network profile
profile = SocialNetworkProfile.create!(
  username: 'johndoe',
  display_name: 'John Doe',
  bio: 'Software engineer and coffee enthusiast'
)
```

## Schema Files

Each database has its own schema file:
- `db/schema.rb` (Primary)
- `db/saas_schema.rb` (SaaS)
- `db/social_network_schema.rb` (Social Network)

## Custom Rake Tasks

The application includes custom rake tasks for managing multi-database operations:

- `bin/rails db:migrate:saas` - Run SaaS migrations
- `bin/rails db:migrate:social_network` - Run Social Network migrations
- `bin/rails db:schema:dump:saas` - Dump SaaS schema
- `bin/rails db:schema:dump:social_network` - Dump Social Network schema
