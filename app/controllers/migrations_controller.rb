# frozen_string_literal: true
class MigrationsController < ApplicationController
  before_action :set_params, only: %i[run skip]

  def index
    @pending  = MigrationService.pending_migrations
    @applied  = MigrationService.applied_migrations
    @skipped  = MigrationService.skipped_migrations
  end

  def run
    MigrationService.run(@version)
    flash[:notice] = "Migration #{@version} run successfully"
  rescue StandardError => e
    flash[:alert] = "Error running migration #{@version}: #{e.message}"
  ensure
    redirect_to migrations_path
  end

  def skip
    MigrationService.skip(@version, @reason)
    flash[:notice] = "Migration #{@version} skipped successfully"
  rescue StandardError => e
    flash[:alert] = "Error skipping migration #{@version}: #{e.message}"
  ensure
    redirect_to migrations_path
  end

  private

  def set_params
    @version = params.require(:version)
    @reason  = params[:reason]
  end
end
