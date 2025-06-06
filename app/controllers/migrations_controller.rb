class MigrationsController < ApplicationController
  def index
    @migrations = MigrationService.all_migrations
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
end
