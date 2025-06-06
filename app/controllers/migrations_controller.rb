class MigrationsController < ApplicationController
  before_action :set_database, only: [:database, :show, :run, :skip, :unskip]
  before_action :validate_database, only: [:database, :show, :run, :skip, :unskip]

  def index
    @database_summaries = MigrationService.all_databases_summary
  end

  def database
    @database = params[:database]
    @migrations = MigrationService.all_migrations(@database)
  end
  
  def show
    @migration = MigrationService.find_migration_by_version(params[:id], @database)
    
    if @migration.nil?
      flash[:alert] = "Migration not found"
      redirect_to_appropriate_path
      return
    end
    
    @migration_content = MigrationService.read_migration_content(@migration[:version], @database)
    
    if @migration_content.nil?
      flash[:alert] = "Unable to read migration file"
      redirect_to_appropriate_path
      return
    end
  end
  
  def run
    RunMigrationJob.perform_later(params[:id], @database)
    flash[:notice] = "Migration has been queued for execution on #{@database} database"
    redirect_to_appropriate_path
  end
  
  def skip
    result = MigrationService.skip_migration(params[:id], @database)
    
    if result[:success]
      flash[:notice] = result[:message]
    else
      flash[:alert] = result[:error]
    end
    
    redirect_to_appropriate_path
  end
  
  def unskip
    result = MigrationService.unskip_migration(params[:id], @database)
    
    if result[:success]
      flash[:notice] = result[:message]
    else
      flash[:alert] = result[:error]
    end
    
    redirect_to_appropriate_path
  end

  private

  def set_database
    @database = params[:database] || 'primary'
  end

  def validate_database
    unless MigrationService.enabled_databases.include?(@database)
      flash[:alert] = "Invalid database: #{@database}"
      redirect_to migrations_path
    end
  end

  def redirect_to_appropriate_path
    if @database && @database != 'primary'
      redirect_to database_migrations_path(@database)
    else
      redirect_to migrations_path
    end
  end
end
