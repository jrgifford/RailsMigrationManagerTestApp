class MigrationsController < ApplicationController
  def index
    @migrations = MigrationService.all_migrations
  end
  
  def show
    @migration = MigrationService.find_migration_by_version(params[:id])
    
    if @migration.nil?
      flash[:alert] = "Migration not found"
      redirect_to migrations_path
      return
    end
    
    @migration_content = MigrationService.read_migration_content(@migration[:version])
    
    if @migration_content.nil?
      flash[:alert] = "Unable to read migration file"
      redirect_to migrations_path
      return
    end
  end
  
  def run
    result = MigrationService.run_migration(params[:id])
    
    if result[:success]
      flash[:notice] = result[:message]
    else
      flash[:alert] = result[:error]
    end
    
    redirect_to migrations_path
  end
  
  def skip
    result = MigrationService.skip_migration(params[:id])
    
    if result[:success]
      flash[:notice] = result[:message]
    else
      flash[:alert] = result[:error]
    end
    
    redirect_to migrations_path
  end
  
  def unskip
    result = MigrationService.unskip_migration(params[:id])
    
    if result[:success]
      flash[:notice] = result[:message]
    else
      flash[:alert] = result[:error]
    end
    
    redirect_to migrations_path
  end
end
