require 'rails_helper'

RSpec.describe MigrationsController, type: :controller do
  describe 'GET #index' do
    it 'assigns @migrations and renders index template' do
      migrations = [
        { version: '20231201000000', filename: 'create_users.rb', status: 'applied' },
        { version: '20231202000000', filename: 'add_email_to_users.rb', status: 'pending' }
      ]
      
      allow(MigrationService).to receive(:all_migrations).and_return(migrations)
      
      get :index
      
      expect(assigns(:migrations)).to eq(migrations)
      expect(response).to render_template(:index)
    end
  end

  describe 'POST #run' do
    it 'runs migration and redirects with success message' do
      allow(MigrationService).to receive(:run_migration).with('20231202000000')
        .and_return({ success: true, message: 'Migration completed successfully' })
      
      post :run, params: { id: '20231202000000' }
      
      expect(flash[:notice]).to eq('Migration completed successfully')
      expect(response).to redirect_to(migrations_path)
    end

    it 'handles migration errors and redirects with error message' do
      allow(MigrationService).to receive(:run_migration).with('20231202000000')
        .and_return({ success: false, error: 'Migration failed' })
      
      post :run, params: { id: '20231202000000' }
      
      expect(flash[:alert]).to eq('Migration failed')
      expect(response).to redirect_to(migrations_path)
    end
  end

  describe 'POST #skip' do
    it 'skips migration and redirects with success message' do
      allow(MigrationService).to receive(:skip_migration).with('20231202000000')
        .and_return({ success: true, message: 'Migration marked as skipped' })
      
      post :skip, params: { id: '20231202000000' }
      
      expect(flash[:notice]).to eq('Migration marked as skipped')
      expect(response).to redirect_to(migrations_path)
    end

    it 'handles skip errors and redirects with error message' do
      allow(MigrationService).to receive(:skip_migration).with('20231202000000')
        .and_return({ success: false, error: 'Failed to skip migration' })
      
      post :skip, params: { id: '20231202000000' }
      
      expect(flash[:alert]).to eq('Failed to skip migration')
      expect(response).to redirect_to(migrations_path)
    end
  end
end
