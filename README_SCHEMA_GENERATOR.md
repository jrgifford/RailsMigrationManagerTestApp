# Schema Migration Generator

A tool that reads schemas from JSON files and generates Rails database migrations, one table at a time.

## Features

- **JSON Schema Input**: Define your database schema in a simple JSON format
- **Multi-Database Support**: Generate migrations for different databases (primary, saas, social_network)
- **Comprehensive Column Types**: Support for all Rails column types with options
- **Index Generation**: Create simple, unique, and composite indexes
- **Foreign Key Support**: Define relationships with cascading options
- **Preview Mode**: See generated migrations before creating files
- **Validation**: Validate schema files before generation
- **CLI Integration**: Easy-to-use Rails rake tasks

## Usage

### 1. Generate Example Schema

```bash
rails schema:example
```

This creates `db/example_schema.json` with a sample schema structure.

### 2. Preview Migrations

```bash
rails 'schema:preview[db/example_schema.json]'
rails 'schema:preview[db/example_schema.json,saas]'  # For specific database
```

### 3. Generate Migration Files

```bash
rails 'schema:generate_migrations[db/example_schema.json]'
rails 'schema:generate_migrations[db/example_schema.json,saas]'  # For specific database
```

### 4. Validate Schema

```bash
rails 'schema:validate[db/example_schema.json]'
```

## JSON Schema Format

```json
{
  "version": "1.0",
  "database": "primary",
  "tables": {
    "users": {
      "columns": {
        "id": { "type": "primary_key" },
        "email": { "type": "string", "null": false },
        "name": { "type": "string", "null": false },
        "age": { "type": "integer", "null": true },
        "active": { "type": "boolean", "default": true },
        "created_at": { "type": "datetime", "null": false },
        "updated_at": { "type": "datetime", "null": false }
      },
      "indexes": [
        { "columns": ["email"], "unique": true },
        { "columns": ["name", "email"], "name": "idx_users_name_email" }
      ],
      "foreign_keys": []
    },
    "posts": {
      "columns": {
        "id": { "type": "primary_key" },
        "title": { "type": "string", "null": false },
        "content": { "type": "text" },
        "user_id": { "type": "bigint", "null": false },
        "published_at": { "type": "datetime" },
        "created_at": { "type": "datetime", "null": false },
        "updated_at": { "type": "datetime", "null": false }
      },
      "indexes": [
        { "columns": ["user_id"] },
        { "columns": ["published_at"] }
      ],
      "foreign_keys": [
        { "column": "user_id", "references": "users", "on_delete": "cascade" }
      ]
    }
  }
}
```

## Column Types Supported

- `primary_key`
- `string` (with optional `limit`)
- `text`
- `integer`
- `bigint`
- `float`
- `decimal` (with optional `precision` and `scale`)
- `boolean`
- `datetime`
- `date`
- `time`
- `binary`
- `json`

## Column Options

- `null`: `true` or `false`
- `default`: Default value (strings, booleans, numbers)
- `limit`: Character/byte limit for string/text columns
- `precision`: Precision for decimal columns
- `scale`: Scale for decimal columns

## Index Options

- `unique`: `true` for unique indexes
- `name`: Custom index name
- `columns`: Array of column names (supports composite indexes)

## Foreign Key Options

- `column`: The foreign key column name
- `references`: The referenced table name
- `on_delete`: Action on delete (`cascade`, `restrict`, `nullify`, `set_default`)
- `on_update`: Action on update (`cascade`, `restrict`, `nullify`, `set_default`)

## Database Support

The tool integrates with the existing multi-database setup:

- **primary**: `db/migrate/` (default)
- **saas**: `db/saas_migrate/`
- **social_network**: `db/social_network_migrate/`

## Integration with Migration Manager

Generated migrations automatically appear in the Migration Manager UI at `/migrations` and can be:

- Previewed before execution
- Run individually
- Skipped if needed
- Tracked with status

## Example Output

Running `rails 'schema:generate_migrations[db/example_schema.json]'` produces:

```
🚀 Schema Migration Generator Results
==================================================
Database: primary
Schema file: db/example_schema.json

✅ Successfully generated 2 migration(s):
   📄 20250606015551_create_users.rb (users)
      Path: /path/to/app/db/migrate/20250606015551_create_users.rb
   📄 20250606015551_create_posts.rb (posts)
      Path: /path/to/app/db/migrate/20250606015551_create_posts.rb

📋 Next steps:
1. Review the generated migration files
2. Run migrations using: rails db:migrate
3. Or use the Migration Manager UI at /migrations
```

## Generated Migration Example

For the users table:

```ruby
class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :name, null: false
      t.integer :age, null: true
      t.boolean :active, default: true
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end

    add_index :users, :email, unique: true
    add_index :users, ["name", "email"], name: 'idx_users_name_email'
  end
end
```

## Error Handling

The tool provides comprehensive error handling:

- **File not found**: Clear error message with file path
- **Invalid JSON**: JSON parsing error with line information
- **File creation errors**: Permission or disk space issues
- **Schema validation**: Missing required fields or invalid structure

## Performance

- **One table at a time**: Generates separate migration files for each table
- **Timestamp ordering**: Uses Rails migration timestamp format for proper ordering
- **Directory creation**: Automatically creates migration directories if missing
- **Conflict detection**: Handles naming conflicts gracefully

## Future Enhancements

- **Schema diff**: Compare schema files and generate change migrations
- **Rollback support**: Generate down migrations for schema changes
- **Data seeding**: Include seed data generation from schema
- **Schema export**: Export existing database schema to JSON format
- **Web UI**: Browser-based schema editor and migration generator
