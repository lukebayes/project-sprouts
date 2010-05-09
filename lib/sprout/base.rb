# External tools and std libs:
require 'rake'
require 'delegate'

# Core, Process and Platform support:
require 'sprout/version'
require 'sprout/constants'
require 'sprout/progress_bar'
require 'sprout/string'
require 'sprout/concern'
require 'sprout/log'
require 'sprout/errors'
require 'sprout/platform'
require 'sprout/process_runner'
require 'sprout/user'

# This is a fix for Issue #106
# http://code.google.com/p/projectsprouts/issues/detail?id=106
# Which is created because the new version (1.0.1) of RubyGems
# includes open-uri, while older versions do not.
# When open-uri is included twice, we get a bunch of nasty
# warnings because constants are being overwritten.
gem_version = Gem::Version.new(Gem::RubyGemsVersion) 
if(gem_version != Gem::Version.new('1.0.1')) 
  require 'open-uri'
end

# File, Archive and Network support:
require 'sprout/archive_unpacker'
require 'sprout/file_target'
require 'sprout/remote_file_loader'
require 'sprout/remote_file_target'

# External Packaging and distribution support:
require 'sprout/specification'
require 'sprout/tool'
require 'sprout/tool/task'

module Sprout

  module Base
    extend Concern

    module ClassMethods

      ##
      # Tool Specifications should register their executables with this method
      # so that Tasks can later call +load_executable+ to retrieve the path to 
      # the actual executable file.
      #
      def register_executable name, gem_name, gem_version, path
        path = File.expand_path path
        if(!File.exists? path )
            raise Sprout::Errors::UsageError.new "Cannot find registered executable at: #{path}. Looks like there's a problem with a #{name}.sproutspec."
        end
        key = "#{name}-#{gem_name}"
        if(executables.has_key?(key) && executables[key][:gem_version] != gem_version)
          raise Sprout::Errors::ExecutableRegistrationError.new "Cannot register an executable with the same name (#{name}) and different versions (#{gem_version}) vs (#{executables[key][:gem_version]})."
        end
        executables[key] = { 
                             :name        => name,
                             :gem_name    => gem_name,
                             :gem_version => gem_version,
                             :path        => path
                           }
      end

      ##
      # This method is generally called by the Sprout::Tool,
      # and it the idea is that we can retrive registered executables with the 
      # exe name, gem name and options gem version (or Gem::Requirement).
      #
      # In order to get the correct tools to register, you should probably
      # ensure they are added to your project Gemfile.
      #
      def load_executable name, gem_name, gem_version=nil
        # puts "load_executable with name: #{name} gem_name: #{gem_name} gem_version: #{gem_version}"
        require_gem_for_executable gem_name
        begin
          ensure_version_requirement executables["#{name}-#{gem_name}"], gem_version
        rescue NoMethodError => e
          raise Sprout::Errors::MissingExecutableError.new "The requested executable (#{name}) in gem (#{gem_name}) and version (#{gem_version}) does not appear to be loaded."
        end
      end

      def executables
        @executables ||= {}
      end

      def cache
        File.join(current_user.application_home('sprout'), 'cache', Sprout::VERSION::MAJOR_MINOR)
      end

      def current_user
        User.create
      end

      private

      def ensure_version_requirement exe, version
        exe_version = Gem::Version.create exe[:gem_version]
        req_version = Gem::Requirement.create version
        if(req_version.satisfied_by? exe_version)
          exe[:path]
        else
          raise Sprout::Errors::VersionRequirementNotMetError.new "Could not meet the version requirement of (#{version}) with (#{exe[:gem_name]} #{exe[:gem_version]}). \n\nYou probably need to update your Gemfile and run 'bundle install' to update your local gems."
        end
      end

      def require_gem_for_executable name
        begin
          require name
        rescue LoadError => e
          raise Sprout::Errors::MissingExecutableError.new "Could not load the required file (#{name}) - Do you need to run 'bundle install'?"
        end
      end

    end
  end
end

