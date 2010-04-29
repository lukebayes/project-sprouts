require 'yaml'

module Sprout

  # This is a class that is generally used by the Sprout::Specification::add_file_target method.
  #
  # File targets are files that are embedded into (or referred to by) a RubyGem in such a way 
  # that Sprouts can use them as a library or executable.
  #
  # File targets can be universally useful, or they can be configured for a particular platform.
  #
  class FileTarget

    attr_accessor :name
    attr_accessor :files
    attr_accessor :platform

    def initialize
      @files = []
      yield self if block_given?
    end
 end
end

