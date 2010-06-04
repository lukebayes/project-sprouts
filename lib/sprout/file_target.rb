
module Sprout

  # This is a class that is generally used by the Sprout::Specification::add_file_target method.
  #
  # File targets are files that are embedded into (or referred to by) a RubyGem in such a way 
  # that Sprouts can use them as a library or executable.
  #
  # A given FileTarget may be configured to work on a specific platform, or it may be
  # universal.
  #
  class FileTarget

    attr_accessor :load_path
    attr_accessor :pkg_name
    attr_accessor :pkg_version
    attr_accessor :platform

    attr_reader :executables
    attr_reader :libraries

    def initialize
      @executables = []
      @libraries   = []
      @load_path   = ''
      @platform    = :universal
      yield self if block_given?
    end

    ##
    # Add a library to the RubyGem package.
    # 
    # @name Symbol that will be used to retrieve this library later.
    # @path File, Path or Array of files that will be associated with this
    # library and copied to the target lib.
    #
    # If the path is a directory, all files forward of that directory
    # will be copied into the RubyGem.
    # 
    def add_library name, path
      libraries << { :name => name, :path => path, :file_target => self }
    end

    ##
    # Add an executable to the RubyGem package.
    #
    # @name Symbol that will be used to retrieve this executable later.
    # @target The relative path to the executable that will be associated
    # with this name.
    #
    def add_executable name, path
      path = expand_executable_path path
      executables << Sprout::ExecutableTarget.new( :name => name, :path => path, :file_target => self )
    end

    def to_s
      "[FileTarget type=#{type} platform=#{platform}]"
    end

    def validate
      raise Sprout::Errors::UsageError.new "FileTarget.pkg_name is required" if pkg_name.nil?
      raise Sprout::Errors::UsageError.new "FileTarget.pkg_version is required" if pkg_version.nil?
    end

    def expand_executable_path path
      File.join load_path, path
    end

  end
end

