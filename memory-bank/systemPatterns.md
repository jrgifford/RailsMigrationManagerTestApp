# System Patterns - Rails Migration Manager

## Architecture Overview
Simple 3-layer Rails architecture focused on separation of concerns:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ MigrationsController │ -> │ MigrationService │ -> │ ActiveRecord     │
│ (Web Interface)      │    │ (Business Logic) │    │ (Data Layer)     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Key Design Patterns

### Service Object Pattern
**`MigrationService`** encapsulates all migration-related business logic:
- **Static methods**: All operations are class-level for simplicity
- **Single responsibility**: Only handles migration status and execution
- **Rails integration**: Uses ActiveRecord::MigrationContext for execution
- **Data aggregation**: Combines file system and database queries

### Controller as Coordinator
**`MigrationsController`** acts as thin coordinator:
- **Delegation**: All logic delegated to MigrationService
- **Error handling**: Catches exceptions and converts to flash messages
- **Redirection**: Always redirects after POST actions (PRG pattern)
- **Parameter extraction**: Uses strong parameters and before_actions

### ActiveRecord Model for State
**`SkippedMigration`** tracks skipped migrations:
- **Validation-heavy**: Ensures data integrity at model level
- **Timestamps**: Tracks when migrations were skipped and reasons
- **Uniqueness**: Prevents duplicate skip records

## File Organization Patterns

### Rails Conventions
- **Controllers**: Single controller handling all migration actions
- **Services**: Business logic extracted to service objects
- **Models**: Simple ActiveRecord models with validations
- **Views**: Basic ERB templates (planned)

### Migration Detection Logic
1. **File Discovery**: Scan `db/migrate/` directory for `*.rb` files
2. **Version Extraction**: Parse version from filename prefix
3. **Status Resolution**: Cross-reference with `schema_migrations` and `skipped_migrations`
4. **Categorization**: Group into pending/applied/skipped collections

## Data Flow Patterns

### Read Operations (Index)
```
Controller#index -> Service.pending_migrations
                 -> Service.applied_migrations  
                 -> Service.skipped_migrations
```

### Write Operations (Run/Skip)
```
Controller#run -> Service.run(version) -> ActiveRecord::MigrationContext.up
Controller#skip -> Service.skip(version, reason) -> SkippedMigration.create!
```

### Error Handling Flow
```
Service Exception -> Controller Rescue -> Flash Message -> Redirect
```

## Database Schema Patterns

### Rails Standard Tables
- **`schema_migrations`**: Rails built-in table tracking applied migrations
- **`ar_internal_metadata`**: Rails internal metadata

### Custom Tracking Table
- **`skipped_migrations`**: Custom table with:
  - `version` (string, unique) - Migration version number
  - `filename` (string) - Original migration filename
  - `skipped_at` (datetime) - When skip decision was made
  - `reason` (string) - Why migration was skipped

## Testing Patterns

### RSpec Structure
- **Controller specs**: Test HTTP interactions and flash messages
- **Service specs**: Test business logic with mocked Rails components
- **Model specs**: Test validations and database constraints
- **Factory patterns**: Use FactoryBot for test data generation

### Mocking Strategy
- **Rails components**: Mock ActiveRecord::MigrationContext for service tests
- **File system**: Mock Dir.glob for migration file discovery
- **Database**: Use test database with proper cleanup between tests

## Future Extraction Patterns

### Gem Preparation
- **Engine pattern**: Code structured for easy Rails Engine extraction
- **Configuration**: Environment-specific behavior isolated
- **Dependencies**: Minimal external dependencies for easier packaging
- **Namespace**: Clear class organization for gem extraction
