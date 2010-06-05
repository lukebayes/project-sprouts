# External tools and std libs:
require 'rake'
require 'delegate'

# Core, Process and Platform support:
require 'sprout/version'
require 'sprout/constants'
require 'sprout/progress_bar'
require 'sprout/dir'
require 'sprout/string'
require 'sprout/concern'
require 'sprout/log'
require 'sprout/errors'
require 'sprout/platform'
require 'sprout/process_runner'
require 'sprout/system'
require 'sprout/ruby_feature'

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
require 'sprout/rdoc_parser'
require 'sprout/specification'
require 'sprout/executable'

# Generators
require 'sprout/generator/command'
require 'sprout/generator/manifest'
require 'sprout/generator/file_manifest'
require 'sprout/generator/template_manifest'
require 'sprout/generator/directory_manifest'
require 'sprout/generator/base'

# Libraries
require 'sprout/library'

module Sprout
  module Base
    extend Concern

    module ClassMethods

      def cache
        File.join(sprout_home, 'cache')
      end

      def sprout_home
        File.join(current_system.application_home('sprouts'), Sprout::VERSION::MAJOR_MINOR)
      end

      def generator_cache
        File.join cache, 'generators'
      end

      def current_system
        Sprout::System.create
      end

    end
  end
end

# TODO: the included 'files' should get modified by the following expressions:
      #included_files = FileList["**/*"].exclude /.DS_Store|generated|.svn|.git|airglobal.swc|airframework.swc/

