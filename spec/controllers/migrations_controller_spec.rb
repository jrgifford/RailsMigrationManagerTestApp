# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MigrationsController, type: :controller do
  render_views
  describe 'GET #index' do
    let(:pending) { [{ version: '1', filename: '001_create.rb' }] }
    let(:applied) { ['20200101'] }
    let(:skipped) { ['20200202'] }

    before do
      allow(MigrationService).to receive(:pending_migrations).and_return(pending)
      allow(MigrationService).to receive(:applied_migrations).and_return(applied)
      allow(MigrationService).to receive(:skipped_migrations).and_return(skipped)
    end

    it 'assigns pending, applied, skipped and renders index' do
      get :index
      expect(assigns(:pending)).to eq(pending)
      expect(assigns(:applied)).to eq(applied)
      expect(assigns(:skipped)).to eq(skipped)
      expect(response).to render_template(:index)
    end
  end

  describe 'POST #run' do
    let(:version) { '123' }

    context 'when successful' do
      before do
        allow(MigrationService).to receive(:run).with(version)
      end

      it 'calls the service and redirects with notice' do
        post :run, params: { version: version }
        expect(MigrationService).to have_received(:run).with(version)
        expect(flash[:notice]).to eq("Migration #{version} run successfully")
        expect(response).to redirect_to(migrations_path)
      end
    end

    context 'when an error occurs' do
      before do
        allow(MigrationService).to receive(:run).with(version).and_raise(StandardError.new('fail'))
      end

      it 'sets alert and redirects' do
        post :run, params: { version: version }
        expect(flash[:alert]).to eq("Error running migration #{version}: fail")
        expect(response).to redirect_to(migrations_path)
      end
    end
  end

  describe 'POST #skip' do
    let(:version) { '456' }
    let(:reason) { 'because' }

    context 'when successful' do
      before do
        allow(MigrationService).to receive(:skip).with(version, reason)
      end

      it 'calls the service with reason and redirects with notice' do
        post :skip, params: { version: version, reason: reason }
        expect(MigrationService).to have_received(:skip).with(version, reason)
        expect(flash[:notice]).to eq("Migration #{version} skipped successfully")
        expect(response).to redirect_to(migrations_path)
      end
    end

    context 'when an error occurs' do
      before do
        allow(MigrationService).to receive(:skip).with(version, reason).and_raise(StandardError.new('fail skip'))
      end

      it 'sets alert and redirects' do
        post :skip, params: { version: version, reason: reason }
        expect(flash[:alert]).to eq("Error skipping migration #{version}: fail skip")
        expect(response).to redirect_to(migrations_path)
      end
    end
  end
end
