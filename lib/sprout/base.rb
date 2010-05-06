require 'rake'

# Core, Process and Platform support:
require 'sprout/string'
require 'sprout/concern'
require 'sprout/log'
require 'sprout/errors'
require 'sprout/platform'
require 'sprout/process_runner'
require 'sprout/user'

# File, Archive and Network support:
require 'sprout/archive_unpacker'
require 'sprout/file_target'
require 'sprout/remote_file_target'

# External Packaging and distribution support:
require 'sprout/specification'
require 'sprout/tool'

module Sprout

  module Base
    extend Concern

    module ClassMethods

      ##
      # Tool Specifications should register their executables with this method
      # so that Tasks can later call +get_executable+ to retrieve the path to 
      # the actual executable file.
      #
      def register_executable name, gem_name, path, gem_version
        key = "#{name}-#{gem_name}"
        executables[key] = { :name => name, :gem_name => gem_name, :path => path, :gem_version => gem_version }
      end

      ##
      # This method is generally called by the Sprout::Tool,
      # and it the idea is that we can retrive registered executables with the 
      # exe name, gem name and options gem version (or Gem::Requirement).
      #
      # In order to get the correct tools to register, you should probably
      # ensure they are added to your project Gemfile.
      #
      def get_executable name, gem_name, gem_version=nil
        # puts "get_executable with name: #{name} gem_name: #{gem_name} gem_version: #{gem_version}"
        require_executable_gem gem_name
        begin
          ensure_version_requirement executables["#{name}-#{gem_name}"], gem_version
        rescue NoMethodError => e
          raise Sprout::Errors::MissingExecutableError.new "The requested executable (#{name}) in gem (#{gem_name}) and version (#{gem_version}) does not appear to be loaded."
        end
      end

      private

      def ensure_version_requirement exe, version
        exe_version = Gem::Version.create exe[:gem_version]
        req_version = Gem::Requirement.create version
        if(req_version.satisfied_by? exe_version)
          exe[:path]
        else
          raise Sprout::Errors::VersionRequirementNotMetError.new "Could not meet the version requirement of (#{version}) with #{exe[:gem_name]} #{exe[:gem_version]}"
        end
      end

      def executables
        @executables ||= {}
      end

      def require_executable_gem name
        #require name
      end

    end
  end
end

