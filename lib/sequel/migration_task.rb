require 'rake/tasklib'
require 'sequel'
require 'sequel/extensions/migration'

module Sequel

  class MigrationTask < Rake::TaskLib

    attr_accessor :directory, :db, :table, :column

    def initialize(options = {})
      self.directory = options[:directory]
      self.db        = options[:db]
      self.table     = options[:table]
      self.column    = options[:column]

      yield(self) if block_given?

      if self.directory.nil?
        raise "Migration directory ':directory' must be defined"
      end
      define_tasks
    end

    private

    def define_tasks

      desc "Sets up the environment for the migration task"
      task :environment

      desc "Migrates the database to [:version] or the latest version"
      task :migrate, [:version] => :environment do |t, args|
        db = if defined?(DB)
               DB
             else
               self.db
             end
        if db.nil?
          fail('No database has been defined.  Either create a DB constant' +
               ' in your :environment task or set the @db variable in the' +
               ' MigrationTask definition.')
        end

        Sequel::Migrator.run(db,
                             self.directory,
                             migration_options(args[:version]))
      end
    end

    def migration_options(version = nil)
      options = {}
      options[:table] = self.table unless self.table.nil?
      options[:column] = self.column unless self.column.nil?
      options[:target] = version unless version.nil?
      options
    end
  end
end
