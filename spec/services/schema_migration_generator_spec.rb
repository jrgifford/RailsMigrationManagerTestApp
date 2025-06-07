require 'rails_helper'
require 'tempfile'

RSpec.describe SchemaMigrationGenerator, type: :service do
  let(:example_schema) do
    {
      "version" => "1.0",
      "database" => "primary",
      "tables" => {
        "users" => {
          "columns" => {
            "id" => { "type" => "primary_key" },
            "email" => { "type" => "string", "null" => false },
            "name" => { "type" => "string", "null" => false },
            "age" => { "type" => "integer", "null" => true },
            "active" => { "type" => "boolean", "default" => true },
            "created_at" => { "type" => "datetime", "null" => false },
            "updated_at" => { "type" => "datetime", "null" => false }
          },
          "indexes" => [
            { "columns" => ["email"], "unique" => true },
            { "columns" => ["name", "email"], "name" => "idx_users_name_email" }
          ],
          "foreign_keys" => []
        },
        "posts" => {
          "columns" => {
            "id" => { "type" => "primary_key" },
            "title" => { "type" => "string", "null" => false },
            "content" => { "type" => "text" },
            "user_id" => { "type" => "bigint", "null" => false },
            "published_at" => { "type" => "datetime" },
            "created_at" => { "type" => "datetime", "null" => false },
            "updated_at" => { "type" => "datetime", "null" => false }
          },
          "indexes" => [
            { "columns" => ["user_id"] },
            { "columns" => ["published_at"] }
          ],
          "foreign_keys" => [
            { "column" => "user_id", "references" => "users", "on_delete" => "cascade" }
          ]
        }
      }
    }
  end

  let(:temp_schema_file) do
    file = Tempfile.new(['test_schema', '.json'])
    file.write(JSON.pretty_generate(example_schema))
    file.close
    file
  end

  after do
    temp_schema_file.unlink if temp_schema_file
  end

  describe '.example_schema' do
    it 'returns a valid example schema' do
      schema = described_class.example_schema
      
      expect(schema).to have_key('version')
      expect(schema).to have_key('database')
      expect(schema).to have_key('tables')
      expect(schema['tables']).to have_key('users')
      expect(schema['tables']).to have_key('posts')
    end
  end

  describe '#initialize' do
    context 'with valid schema file' do
      it 'initializes successfully' do
        generator = described_class.new(temp_schema_file.path)
        
        expect(generator.schema_data).to eq(example_schema)
        expect(generator.database).to eq('primary')
      end
    end

    context 'with custom database' do
      it 'sets the database correctly' do
        generator = described_class.new(temp_schema_file.path, 'saas')
        
        expect(generator.database).to eq('saas')
      end
    end

    context 'with non-existent file' do
      it 'raises an error' do
        expect {
          described_class.new('/non/existent/file.json')
        }.to raise_error("Schema file not found: /non/existent/file.json")
      end
    end

    context 'with invalid JSON' do
      let(:invalid_json_file) do
        file = Tempfile.new(['invalid', '.json'])
        file.write('{ invalid json }')
        file.close
        file
      end

      after do
        invalid_json_file.unlink
      end

      it 'raises a JSON parse error' do
        expect {
          described_class.new(invalid_json_file.path)
        }.to raise_error(/Invalid JSON in schema file/)
      end
    end
  end

  describe '#preview_migration' do
    let(:generator) { described_class.new(temp_schema_file.path) }

    it 'generates correct migration content for users table' do
      table_definition = example_schema['tables']['users']
      content = generator.preview_migration('users', table_definition)

      expect(content).to include('class CreateUsers < ActiveRecord::Migration[7.1]')
      expect(content).to include('create_table :users do |t|')
      expect(content).to include('t.string :email, null: false')
      expect(content).to include('t.string :name, null: false')
      expect(content).to include('t.integer :age, null: true')
      expect(content).to include('t.boolean :active, default: true')
      expect(content).to include('add_index :users, :email, unique: true')
      expect(content).to include('add_index :users, ["name", "email"], name: \'idx_users_name_email\'')
    end

    it 'generates correct migration content for posts table with foreign keys' do
      table_definition = example_schema['tables']['posts']
      content = generator.preview_migration('posts', table_definition)

      expect(content).to include('class CreatePosts < ActiveRecord::Migration[7.1]')
      expect(content).to include('create_table :posts do |t|')
      expect(content).to include('t.string :title, null: false')
      expect(content).to include('t.text :content')
      expect(content).to include('t.bigint :user_id, null: false')
      expect(content).to include('add_index :posts, :user_id')
      expect(content).to include('add_foreign_key :posts, :users, column: :user_id, on_delete: :cascade')
    end
  end

  describe '#generate_table_migration' do
    let(:generator) { described_class.new(temp_schema_file.path) }
    let(:migration_dir) { Dir.mktmpdir }

    before do
      allow(Rails).to receive(:root).and_return(Pathname.new(migration_dir))
      allow(generator).to receive(:get_migration_path).and_return('db/migrate')
    end

    after do
      FileUtils.rm_rf(migration_dir)
    end

    it 'creates a migration file successfully' do
      table_definition = example_schema['tables']['users']
      result = generator.generate_table_migration('users', table_definition)

      expect(result[:success]).to be true
      expect(result[:table_name]).to eq('users')
      expect(result[:filename]).to match(/\d{14}_create_users\.rb/)
      expect(result[:migration_name]).to eq('create_users')
      expect(result[:database]).to eq('primary')
      
      # Check that file was actually created
      expect(File.exist?(result[:path])).to be true
      
      # Check file content
      content = File.read(result[:path])
      expect(content).to include('class CreateUsers < ActiveRecord::Migration[7.1]')
    end

    it 'handles file creation errors gracefully' do
      # Create a scenario where file creation fails
      allow(File).to receive(:write).and_raise(StandardError.new('Permission denied'))
      
      table_definition = example_schema['tables']['users']
      result = generator.generate_table_migration('users', table_definition)

      expect(result[:success]).to be false
      expect(result[:error]).to include('Failed to create migration')
    end
  end

  describe '#generate_all_migrations' do
    let(:generator) { described_class.new(temp_schema_file.path) }
    let(:migration_dir) { Dir.mktmpdir }

    before do
      allow(Rails).to receive(:root).and_return(Pathname.new(migration_dir))
      allow(generator).to receive(:get_migration_path).and_return('db/migrate')
    end

    after do
      FileUtils.rm_rf(migration_dir)
    end

    it 'generates migrations for all tables' do
      results = generator.generate_all_migrations

      expect(results.length).to eq(2)
      
      users_result = results.find { |r| r[:table_name] == 'users' }
      posts_result = results.find { |r| r[:table_name] == 'posts' }

      expect(users_result[:success]).to be true
      expect(posts_result[:success]).to be true
      
      expect(File.exist?(users_result[:path])).to be true
      expect(File.exist?(posts_result[:path])).to be true
    end
  end

  describe 'private methods' do
    let(:generator) { described_class.new(temp_schema_file.path) }

    describe '#format_column_definition' do
      it 'formats string column correctly' do
        column_def = { 'type' => 'string', 'null' => false }
        result = generator.send(:format_column_definition, 'email', column_def)
        
        expect(result).to eq('      t.string :email, null: false')
      end

      it 'formats column with default value' do
        column_def = { 'type' => 'boolean', 'default' => true }
        result = generator.send(:format_column_definition, 'active', column_def)
        
        expect(result).to eq('      t.boolean :active, default: true')
      end

      it 'formats column with limit' do
        column_def = { 'type' => 'string', 'limit' => 100 }
        result = generator.send(:format_column_definition, 'name', column_def)
        
        expect(result).to eq('      t.string :name, limit: 100')
      end
    end

    describe '#format_default_value' do
      it 'formats string defaults with quotes' do
        result = generator.send(:format_default_value, 'active')
        expect(result).to eq("'active'")
      end

      it 'formats boolean defaults without quotes' do
        result = generator.send(:format_default_value, true)
        expect(result).to eq(true)
      end

      it 'formats numeric defaults without quotes' do
        result = generator.send(:format_default_value, 42)
        expect(result).to eq(42)
      end
    end

    describe '#format_index_definition' do
      it 'formats simple index' do
        index_def = { 'columns' => ['email'] }
        result = generator.send(:format_index_definition, 'users', index_def)
        
        expect(result).to eq('    add_index :users, :email')
      end

      it 'formats unique index' do
        index_def = { 'columns' => ['email'], 'unique' => true }
        result = generator.send(:format_index_definition, 'users', index_def)
        
        expect(result).to eq('    add_index :users, :email, unique: true')
      end

      it 'formats composite index' do
        index_def = { 'columns' => ['name', 'email'] }
        result = generator.send(:format_index_definition, 'users', index_def)
        
        expect(result).to eq('    add_index :users, ["name", "email"]')
      end
    end

    describe '#format_foreign_key_definition' do
      it 'formats basic foreign key' do
        fk_def = { 'column' => 'user_id', 'references' => 'users' }
        result = generator.send(:format_foreign_key_definition, 'posts', fk_def)
        
        expect(result).to eq('    add_foreign_key :posts, :users, column: :user_id')
      end

      it 'formats foreign key with on_delete' do
        fk_def = { 'column' => 'user_id', 'references' => 'users', 'on_delete' => 'cascade' }
        result = generator.send(:format_foreign_key_definition, 'posts', fk_def)
        
        expect(result).to eq('    add_foreign_key :posts, :users, column: :user_id, on_delete: :cascade')
      end
    end
  end
end
