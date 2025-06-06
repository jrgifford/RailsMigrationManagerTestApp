# 🛠️ Rails Migration Manager - Proof of Concept

## Overview

A simple web-based UI to view and manually run Rails database migrations. This is a proof of concept that will later be developed into a gem.

---

## 🎯 Core Goals (MVP)

- **View migrations**: Show pending, applied, and skipped migrations
- **Run migrations**: Execute pending migrations one at a time
- **Skip migrations**: Mark migrations as skipped without running them
- **Simple UI**: Clean interface to manage migrations

---

## 🧱 Simple Architecture

### Components

| Component | Description |
|-----------|-------------|
| **MigrationsController** | Handles viewing and running migrations |
| **Migration Service** | Manages migration execution and status |
| **Simple Views** | Basic HTML forms and tables |

---

## 🔧 Implementation Plan

### Phase 1: Basic Functionality
1. **Controller**: `MigrationsController` with `index`, `run`, and `skip` actions
2. **Service**: `MigrationService` to handle migration logic
3. **Views**: Simple HTML table showing migration status
4. **Routes**: Mount under `/migrations`

### Phase 2: Enhanced Features
1. **Styling**: Add basic CSS for better UX
2. **Flash messages**: Show success/error feedback
3. **Confirmation**: Add "Are you sure?" prompts

---

## 📋 Core Features

### Migration Status Display
- Show migration filename, version, and status (pending/applied/skipped)
- Display in a simple HTML table
- Use color coding for status (green=applied, yellow=pending, red=skipped)

### Migration Actions
- **Run**: Execute a single pending migration
- **Skip**: Mark migration as skipped (add to schema_migrations without running)
- **Refresh**: Reload migration status

### Skipped Migration Tracking
- Store skipped migrations in a simple model: `SkippedMigration`
- Track version, filename, and timestamp when skipped

---

## 🗂️ File Structure

```
app/
├── controllers/
│   └── migrations_controller.rb
├── models/
│   └── skipped_migration.rb
├── services/
│   └── migration_service.rb
├── views/
│   └── migrations/
│       └── index.html.erb
└── config/
    └── routes.rb (add migration routes)
```

---

## 🎨 Simple UI Design

- **Route**: `/migrations`
- **Layout**: Use default Rails layout
- **Styling**: Minimal CSS, focus on functionality
- **Components**:
  - Migration table with status indicators
  - Action buttons for each migration
  - Refresh button to reload status

---

## 🧪 Basic Testing

### What to Test
1. **Controller**: Basic actions work (index, run, skip)
2. **Service**: Migration status detection
3. **Model**: SkippedMigration creation and querying

### Testing Tools
- Set up and use rspec and rspec-rails
- Simple controller and model tests

---

## 🚀 Getting Started

### Required Files
1. Migration for `SkippedMigration` model
2. Controller with basic actions
3. Service class for migration logic
4. Simple view template
5. Routes configuration

### Development Approach
Write rspecs unit tests every step of the way. But we'll do manual testing of the UI in the browser. Keep the logic on the backend, and the UI a basic crud app.

1. Start with the model and migration
2. Build the service layer
3. Create controller actions
4. Add simple views
5. Test manually in browser

---

## 🔮 Future Enhancements (Post-POC)

- Background job execution
- Multi-database support  
- Authorization/authentication
- API endpoints for deployment
- Advanced UI with JavaScript
- Comprehensive testing
- Gem packaging

---

## 📝 Notes

- Keep it simple - focus on core functionality
- Use Rails conventions
- Avoid external dependencies initially
- Make it easy to extract into a gem later
- Test manually in development environment
