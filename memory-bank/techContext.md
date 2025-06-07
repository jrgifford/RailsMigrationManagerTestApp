# Tech Context - Rails Migration Manager

## Technologies
- Ruby 3.4.4
- Rails ~7.1.5
- SQLite3 database
- Importmap for JavaScript (importmap-rails)
- Hotwire: Turbo Rails and Stimulus Rails
- Jbuilder for JSON APIs
- Asset pipeline: Sprockets Rails
- Puma web server

## Development Setup
- Ruby version defined in `.ruby-version`
- Database configured via `config/database.yml` (SQLite3)
- Application boot via `bin/setup`
- RSpec configured in `spec/rails_helper.rb` and `spec/spec_helper.rb`
- FactoryBot setup under `spec/factories`
- DatabaseCleaner configured in `spec/support/database_cleaner.rb`
- Guard with Guard-RSpec for continuous testing
- Web Console available in development

## Technical Constraints
- No external dependencies outside Rails default stack
- Minimal JavaScript, using Stimulus controllers only as needed
- Follow Rails conventions (MVC, Service Objects, Strong Parameters)
- Use Post-Redirect-Get pattern for POST actions
- Flash messages for user feedback

## Tooling & Workflows
- Migration execution via `ActiveRecord::MigrationContext`
- Model validations enforced in `SkippedMigration`
- Controller thin: delegates to `MigrationService`
- Testing with RSpec, FactoryBot, Faker, DatabaseCleaner
- Automatic test runs with Guard
- Debugging via `debug` gem and Rails Web Console
