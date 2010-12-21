
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
      @load_path   = '.'
      @platform    = :universal
      yield self if block_given?
    end

    ##
    # This is a template method that will be called
    # so that RemoteFileTarget subclasses and load
    # the appropriate files at the appropriate time.
    # Admittedly kind of smelly, other ideas welcome...
    def resolve
    end

    ##
    # Add a library to the package.
    # 
    # @return [Sprout::Library] The newly created library that was added.
    # @param name [Symbol] Name that will be used to retrieve this library on +load+.
    # @param path [File, Path, Array] File or files that will be associated with 
    #   this library and copied into the target project library folder when loaded. 
    #   (If the path is a directory, all files forward of that directory will be included.)
    def add_library name, path
      if path.is_a?(Array)
        path = path.collect { |p| expand_local_path(p) }
      else
        path = expand_local_path path
      end
      library = Sprout::Library.new( :name => name, :path => path, :file_target => self )
      libraries << library
      library
    end

    ##
    # Add an executable to the RubyGem package.
    #
    # @param name [Symbol] that will be used to retrieve this executable later.
    # @param path [File] relative path to the executable that will be associated
    # with this name.
    #
    def add_executable name, path
      path = expand_local_path path
      executables << OpenStruct.new( :name => name, :path => path, :file_target => self )
    end

    def to_s
      "[FileTarget pkg_name=#{pkg_name} pkg_version=#{pkg_version} platform=#{platform}]"
    end

    def validate
      raise Sprout::Errors::UsageError.new "FileTarget.pkg_name is required" if pkg_name.nil?
      raise Sprout::Errors::UsageError.new "FileTarget.pkg_version is required" if pkg_version.nil?
    end

    ## 
    # This is a template method that is overridden
    # by RemoteFileTarget.
    def expand_local_path path
      File.join load_path, path
    end

  end
end

