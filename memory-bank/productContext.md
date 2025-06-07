# Product Context - Rails Migration Manager

## Why This Project Exists
Rails developers often run `rails db:migrate` blindly, applying all pending migrations at once. This approach lacks visibility and control, leading to issues:

- **No visibility** into what migrations will run before execution
- **All-or-nothing** approach - can't run migrations selectively
- **No tracking** of intentionally skipped migrations
- **Difficult recovery** when migrations fail partway through
- **Production risk** from unexpected migration behavior

## Problems We Solve

### 1. Migration Visibility Gap
**Current State**: Developers run `rails db:migrate` without knowing what will execute
**Our Solution**: Display all migrations categorized by status (pending/applied/skipped) before any action

### 2. Lack of Granular Control
**Current State**: Must run all pending migrations or none
**Our Solution**: Execute migrations one at a time with explicit confirmation

### 3. No Skip Tracking
**Current State**: Problematic migrations are either run anyway or developers lose track of them
**Our Solution**: Formal skip mechanism with reason tracking and timestamps

### 4. Poor Error Recovery
**Current State**: Failed migrations leave database in uncertain state
**Our Solution**: Isolated execution with clear success/failure feedback

## How It Should Work

### User Experience Flow
1. **Navigate** to `/migrations` in development environment
2. **Review** current migration status in organized table view
3. **Choose** to run or skip each pending migration individually
4. **Confirm** each action with reason for skipping (if applicable)
5. **Receive** immediate feedback on success or failure
6. **Track** history of all migration decisions

### Core Interactions
- **View Status**: Clean table showing filename, version, and color-coded status
- **Run Migration**: Single-click execution with success/error feedback
- **Skip Migration**: Record skip decision with mandatory reason
- **Refresh View**: Update status after external migration changes

### User Experience Goals
- **Confidence**: Always know what migrations exist and their status
- **Control**: Choose when and which migrations to run
- **Transparency**: Track all migration decisions with reasons
- **Safety**: Clear feedback and error handling for failed operations
- **Simplicity**: Minimal, intuitive interface focused on core workflow

## Success Metrics
- Developers can see migration status without running commands
- Individual migration execution works reliably
- Skipped migrations are properly tracked with reasons
- UI provides clear feedback for all operations
- Zero confusion about current migration state
