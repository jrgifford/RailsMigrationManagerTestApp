# Rails Migration Manager - Project Brief

## Project Overview
A Rails-based proof of concept for a web UI that provides manual control over database migrations. This is a standalone Rails application that will later be extracted into a gem.

## Core Purpose
Replace blind `rails db:migrate` execution with a visual interface that allows developers to:
- View migration status (pending/applied/skipped)
- Run migrations one at a time with confirmation
- Skip problematic migrations while tracking the decision
- Maintain full visibility into migration state

## Key Problems Solved
1. **Migration Visibility**: Clear overview of what migrations exist and their status
2. **Controlled Execution**: Run migrations individually rather than all at once
3. **Skip Management**: Ability to defer migrations without losing track of them
4. **Error Recovery**: Handle migration failures gracefully with user feedback

## Success Criteria
- ✅ Display migrations categorized by status in a clean web interface
- ✅ Execute individual pending migrations with success/error feedback
- ✅ Record skipped migrations with timestamps and reasons
- ✅ Provide simple, intuitive UI accessible at `/migrations`
- 🔄 Comprehensive test coverage (in progress)
- 🔄 Production-ready error handling and validation

## Technical Scope
- **Current**: Standalone Rails app for proof of concept
- **Future**: Extract to mountable gem for integration into existing Rails apps
- **Focus**: Backend logic with minimal frontend (HTML forms, basic CSS)
- **Testing**: RSpec-driven development with unit and integration tests

## Project Constraints
- Rails conventions only - no external dependencies beyond standard Rails stack
- Simple UI - focus on functionality over aesthetics
- Manual testing in browser for UI validation
- Keep extraction to gem as future consideration in all design decisions
