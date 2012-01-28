require 'spec_helper'

module Sequel

  describe MigrationTask do

    it 'should require a directory' do
      expect {
        MigrationTask.new
      }.to raise_error
    end

    describe 'directory' do
      before do
        @directory = 'migrations'
      end

      it 'should be set from the options' do
        t = MigrationTask.new(:directory => @directory)
        t.directory.should == @directory
      end

      it 'should set directory from the block' do
        t = MigrationTask.new do | task |
          task.directory = @directory
        end
        t.directory.should == @directory
      end
    end

    describe 'db' do
      before do
        @db = mock
      end

      it 'should be set from the options' do
        t = MigrationTask.new(:directory => 'x', :db => @db)
        t.db.should == @db
      end

      it 'should be set from the block' do
        t = MigrationTask.new(:directory => 'x') do | task |
          task.db = @db
        end

        t.db.should == @db
      end
    end


    describe 'column' do
      before do
        @column = 'version_number'
      end

      it 'should be set from the options' do
        t = MigrationTask.new(:directory => 'x', :column => @column)
        t.column.should == @column
      end

      it 'should be set from the block' do
        t = MigrationTask.new(:directory => 'x') do | task |
          task.column = @column
        end

        t.column.should == @column
      end
    end

    describe 'table' do
      before do
        @table = 'schema_information'
      end

      it 'should be set from the options' do
        t = MigrationTask.new(:directory => 'x', :table => @table)
        t.table.should == @table
      end

      it 'should be set from the block' do
        t = MigrationTask.new(:directory => 'x') do | task |
          task.table = @table
        end

        t.table.should == @table
      end
    end

    describe 'tasks' do

      before do
        @db              = mock
        @table           = 'table'
        @column          = 'column'
        @directory       = 'directory'
        @rake            = Rake::Application.new
        Rake.application = @rake
        @task = MigrationTask.new do | t |
          t.db        = @db
          t.table     = @table
          t.column    = @column
          t.directory = @directory
        end
      end

      after do
        if defined?(DB)
          Sequel.module_eval { remove_const :DB }
        end
      end

      it 'should define an environment task' do
        Rake::Task.task_defined?(:environment).should be_true
      end

      it 'should define a migrate task' do
        Rake::Task.task_defined?(:migrate).should be_true
      end

      it 'should define environment as a prerequisite to migrate' do
        Rake::Task[:migrate].prerequisites.include?('environment'
                                                   ).should be_true
      end

      it 'should execute sequel migrations with no version' do
        Sequel::Migrator.should_receive(:run).with(@db, @directory, {
          :table  => @table,
          :column => @column })
          Rake::Task[:migrate].invoke
      end

      it 'should execute sequel migrations with the version' do
        Sequel::Migrator.should_receive(:run).with(@db, @directory, {
          :table  => @table,
          :column => @column,
          :target => 15 })
          Rake::Task[:migrate].invoke(15)
      end

      it 'should execute sequel with no options' do
        @rake = Rake::Application.new
        Rake.application = @rake
        @task = MigrationTask.new do | t |
          t.db = @db
          t.directory = @directory
        end
        Sequel::Migrator.should_receive(:run).with(@db, @directory, {})
        Rake::Task[:migrate].invoke
      end

      it 'should execute migrations using a DB constant' do
        @rake = Rake::Application.new
        Rake.application = @rake
        @task = MigrationTask.new do | t |
          t.directory = @directory
        end
        DB = mock
        Sequel::Migrator.should_receive(:run).with(DB, @directory, {})
        Rake::Task[:migrate].invoke
      end

      it 'should execute migrations using a DB constant' do
        @rake = Rake::Application.new
        Rake.application = @rake
        @task = MigrationTask.new do | t |
          t.directory = @directory
        end
        DB = mock
        Sequel::Migrator.should_receive(:run).with(DB, @directory, {})
        Rake::Task[:migrate].invoke
      end

      it 'should execute migrations on the instance over DB constant' do
        @rake = Rake::Application.new
        Rake.application = @rake
        @task = MigrationTask.new do | t |
          t.db = @db
          t.directory = @directory
        end
        DB = mock
        Sequel::Migrator.should_receive(:run).with(@db, @directory, {})
        Rake::Task[:migrate].invoke
      end
    end
  end
end
