require 'sprout/executable/param'
require 'sprout/executable/collection_param'
require 'sprout/executable/boolean'
require 'sprout/executable/number'
require 'sprout/executable/string_param'
require 'sprout/executable/strings'
require 'sprout/executable/file_param'
require 'sprout/executable/files'
require 'sprout/executable/path'
require 'sprout/executable/paths'
require 'sprout/executable/url'
require 'sprout/executable/urls'
require 'sprout/executable/parameter_factory'
require 'rake/clean'
require 'sprout/executable/base'

module Sprout

  ##
  # The Sprout::Executable module exposes a Domain Specific Language
  # for describing Command Line Interface (CLI) applications.
  #
  # This module can be included by any class, and depending on how that class
  # is used, one can either parse command line arguments into meaningful, 
  # structured data, or delegate ruby code and configuration to an existing,
  # external command line process.
  #
  # Following is an example of how one could define an executable Ruby
  # application using this module:
  #
  # :include: ../../test/fixtures/examples/echo_inputs.rb
  #
  module Executable
    include RubyFeature

    DEFAULT_FILE_EXPRESSION = '/**/**/*'
    DEFAULT_PREFIX          = '--'
    DEFAULT_SHORT_PREFIX    = '-'

  end
end

