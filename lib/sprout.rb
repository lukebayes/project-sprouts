
lib = File.expand_path File.dirname(__FILE__)
$:.unshift lib unless $:.include?(lib)

# External tools and std libs:
require 'rake'
require 'delegate'

# Core, Process and Platform support:
require 'sprout/version'
require 'sprout/progress_bar'
require 'sprout/dir'
require 'sprout/string'
require 'sprout/log'
require 'sprout/errors'
require 'sprout/platform'
require 'sprout/process_runner'
require 'sprout/system'
require 'sprout/concern'
require 'sprout/ruby_feature'

##
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
require 'sprout/daemon'

# Generators
require 'sprout/generator'

# Libraries
require 'sprout/library'

module Sprout

  class << self

    ##
    # @return [Dir] The system-specific path to the writeable cache directory
    # where Sprouts will look for downloaded archives.
    #
    #   puts ">> Sprout Cache: #{Sprout.cache}"
    #
    def cache
      File.join(home, 'cache')
    end

    ##
    # @return [Dir] The location where the currently-running version of Sprouts
    # will write files and generators and their templates.
    #
    #   puts ">> Sprout home: #{Sprout.home}"
    #
    def home
      File.join(current_system.application_home('sprouts'), Sprout::VERSION::MAJOR_MINOR)
    end

    ##
    # @return [Dir] The location where Sprouts will look for generators and their
    # templates.
    #
    #   puts ">> Generator Cache: #{Sprout.generator_cache}"
    #
    def generator_cache
      File.join cache, 'generators'
    end

    ##
    # @return [Sprout::System] That is currently being used to 
    # determine features like the cache path and how external processes
    # are executed.
    #
    #   system = Sprout.current_system
    #   puts ">> System: #{system.inspect}"
    #
    def current_system
      Sprout::System.create
    end

    ##
    # @return [File] Path to the file from the 'caller' property of
    # a Ruby exception.
    #
    # Note: It's a real bummer that this string is colon delimited -
    # The value on Windows often includes a colon...
    # Once again, Windows is dissed by fundamental Ruby decisions.
    def file_from_caller caller_string
      parts = caller_string.split(':')
      str   = parts.shift
      while(parts.size > 0 && !File.exists?(str))
        str << ":#{parts.shift}"
      end
      str
    end
  end
end

