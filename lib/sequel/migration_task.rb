require 'rake/tasklib'
require 'sequel'
require 'sequel/extensions/migration'
require 'logger'

module Sequel

  class MigrationTask < Rake::TaskLib

    attr_accessor :directory, :db, :table, :column

    @@logger = nil

    def initialize(*args)
      debug { "Initializing with arguments #{args.inspect}" }
      options = check_for_options(*args)
      self.directory = options[:directory]# if self.directory.nil?
      self.db        = options[:db] #if self.db.nil?
      self.table     = options[:table] #if self.table.nil?
      self.column    = options[:column] #if self.column.nil?

      check_for_parameters(*args)

      yield(self) if block_given?

      if self.directory.nil?
        raise "Migration directory ':directory' must be defined"
      end
      define_tasks
    end

    def self.logger=
      @@logger
    end

    private

    def self.logger
      return @@logger unless @@logger.nil?
      @@logger = Logger.new(STDOUT)
      if defined?(DEBUG) && DEBUG.true?
        @@logger.level = Logger::DEBUG
      else
        @@logger.level = Logger::FATAL
      end
    end

    def logger
      MigrationTask.logger
    end

    def debug(&block)
      logger.debug('MigrationTask', &block)
    end

    def define_tasks

      desc "Sets up the environment for the migration task"
      task :environment

      desc "Migrates the database to [:version] or the latest version"
      task :migrate, [:version] => :environment do |t, args|
        db = self.db

        if db.nil? && defined?(DB)
          db = DB
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

    def check_for_parameters(*args)
      debug { "Checking for parameters from #{args.inspect}" }
      args_list = args.dup
      args_list.each do | arg |
        debug { "Checking for parameter from #{arg.inspect}" }
        if self.directory.nil? and arg.is_a?(String)
          debug { "Found directory parameter #{arg}" }
          self.directory = args.delete(arg)
        end

        if self.db.nil? and arg.is_a?(Sequel::Database)
          debug { "Found db parameter #{arg}" }
          self.db = args.delete(arg)
        end
      end
    end

    def check_for_options(*args)
      debug { "Checking for options from #{args.inspect}" }
      args_list = args.dup
      args_list.each do | arg |
        next unless arg.is_a?(Hash)
        if arg.keys.include?(:directory) or
          arg.keys.include?(:db) or
          arg.keys.include?(:table) or
          arg.keys.include?(:column)

          debug { "Found options #{arg.inspect}" }
          return args.delete(arg)
        end
      end
      debug { "No options found" }
      {}
    end
  end
end
