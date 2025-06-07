# Implementation Plan – Rails Migration Manager POC

## Overview  
Brief proof-of-concept for a web UI to view, run, and skip Rails database migrations. Built as a standalone Rails app now, later extracted into a gem.

### Core Goals (MVP)
- List migrations by status: pending, applied, skipped  
- Run one pending migration at a time  
- Skip pending migrations (record in DB without executing)  
- Clean, minimal UI  

## Architecture & File Structure  
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
config/
└── routes.rb     # mount `/migrations`
db/
└── migrate/      # generated migration for SkippedMigration
spec/
└── (controller, model, service specs)
```

## Phase 0: Set up the application framework
- Install rspec rails
- Install factory bot
- Install faker
- Install database cleaner

## Phase 1: Data Model & Migrations  
1. Generate `SkippedMigration` ActiveRecord model  
2. Create migration to add `skipped_migrations` table with columns:  
   - `version:string` (unique)  
   - `filename:string`
   - `skipped_at:datetime` (not null)
   - `reason:string` (not null)
3. Run `rails db:migrate` and verify schema

## Phase 2: Service Layer  
1. Create `app/services/migration_service.rb`  
2. Implement methods:  
   - `.pending_migrations`: compare `db/migrate` folder vs `schema_migrations`/`skipped_migrations`  
   - `.applied_migrations`: read from `schema_migrations`  
   - `.skipped_migrations`: read from `SkippedMigration` model  
   - `.run(version)`: invoke Rails migrator for that version  
   - `.skip(version)`: insert record into `skipped_migrations`  
3. Unit test each method (RSpec)

## Phase 3: Controller  
1. Generate `MigrationsController` with actions:  
   - `index` (load status via service)  
   - `run` (POST — calls `.run`, redirects to index with flash)  
   - `skip` (POST — calls `.skip`, redirects with flash)  
2. Strong parameters & error handling  
3. RSpec controller specs

## Phase 4: Views & Routes  
1. Add routes in `config/routes.rb`:  
   ```ruby
   resources :migrations, only: [:index] do
     post :run, on: :collection
     post :skip, on: :collection
   end
   ```  
2. Create `app/views/migrations/index.html.erb`:  
   - Table showing filename, version, status  
   - Color-coded status badges (green/yellow/red)  
   - “Run” and “Skip” buttons for pending rows  
   - “Refresh” button to reload page  
3. Minimal CSS in `app/assets/stylesheets/application.css`

## Phase 5: UI Enhancements (MVP polish)  
1. Add Rails flash messages for success/error  
2. Add JavaScript confirm dialogs on Run/Skip  
3. Basic styling improvements (margins, table stripes)

## Phase 6: Testing & Verification  
1. RSpec:  
   - Model spec for `SkippedMigration` validations  
   - Service specs covering status logic, run/skip behavior (mock Rails migrations)  
   - Controller specs for each action  
2. Manual browser testing:  
   - Navigate to `/migrations`  
   - Verify table, actions, status changes  

## Phase 7: Post-POC / Future Enhancements  
- Gemify extraction & mountable engine  
- Background job support for long migrations  
- Multi-DB support  
- Auth/authz (e.g., Devise + Pundit)  
- API endpoints (JSON)  
- Advanced JS UI (Stimulus/React)  
- Comprehensive integration and system tests  

---

_End of plan. Proceed to ACT MODE when ready to scaffold files and begin implementation._
