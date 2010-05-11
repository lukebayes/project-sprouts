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
require 'sprout/executable'
require 'sprout/file_target'
require 'sprout/remote_file_loader'
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
      # so that Tasks can later call +load_executable+ to retrieve the path to 
      # the actual executable file.
      #
      def register_executable executable
        executables << executable
        executable
      end

      ##
      # This method is generally called by the Sprout::Tool,
      # and it the idea is that we can retrive registered executables with the 
      # exe name, gem name and options gem version (or Gem::Requirement).
      #
      # In order to get the correct tools to register, you should probably
      # ensure they are added to your project Gemfile.
      #
      def load_executable name, pkg_name, version_requirement=nil
        # puts "load_executable with name: #{name} pkg_name: #{pkg_name} pkg_version: #{pkg_version}"
        require_rb_for_executable pkg_name
        executable = executable_for(current_user, pkg_name, name, version_requirement)
        if(executable.nil?)
          message = "The requested executable: (#{name}) from: (#{pkg_name}) and version: "
          message << "(#{version_requirement}) does not appear to be loaded."
          message << "\n\nYou probably need to update your Gemfile and run 'bundle install' "
          message << "to update your local gems."
          raise Sprout::Errors::MissingExecutableError.new message
        end
        executable.path
      end

      def executables
        @executables ||= []
      end

      def cache
        File.join(current_user.application_home('sprout'), 'cache', Sprout::VERSION::MAJOR_MINOR)
      end

      def current_user
        User.create
      end

      private

      def executable_for user, pkg, name, version_requirement
        executables.select do |exe|
          user.can_execute?(exe.platform) && 
            exe.includes_package_name?(pkg) &&
            exe.name == name && 
            exe.satisfies_requirement?(version_requirement)
        end.first
      end

      def require_rb_for_executable name
        begin
          require name
        rescue LoadError => e
          raise Sprout::Errors::MissingExecutableError.new "Could not load the required file (#{name}) - Do you need to run 'bundle install'?"
        end
      end

    end
  end
end

# TODO: the included 'files' should get modified by the following expressions:
      #included_files = FileList["**/*"].exclude /.DS_Store|generated|.svn|.git|airglobal.swc|airframework.swc/

