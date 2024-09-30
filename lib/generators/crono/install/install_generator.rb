# frozen_string_literal: true

require 'rails/generators'
require 'rails/generators/migration'
require 'rails/generators/active_record'

module Crono
  module Generators
    # rails generate crono:install
    class InstallGenerator < ::Rails::Generators::Base
      include Rails::Generators::Migration

      def self.next_migration_number(path)
        ActiveRecord::Generators::Base.next_migration_number(path)
      end

      desc 'Installs crono and generates the necessary configuration files'
      source_root File.expand_path('templates', __dir__)

      def copy_config
        template 'cronotab.rb.erb', 'config/cronotab.rb'
      end

      def create_migrations
        migration_template 'migrations/create_crono_jobs.rb.erb',
                           'db/migrate/create_crono_jobs.rb',
                           migration_version: "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]"
      end

    end
  end
end
