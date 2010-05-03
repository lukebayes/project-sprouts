
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

    attr_accessor :platform
    attr_accessor :files

    attr_reader :executables
    attr_reader :libraries

    def initialize
      @executables = []
      @libraries   = []
      @files       = []
      @platform    = :universal
      yield self if block_given?
      @files       = cleanup_files @files
    end

    ##
    # Add a library to the RubyGem package.
    # 
    # @name Symbol that will be used to retrieve this library later.
    # @target File or Array of files that will be associated with this
    # library and copied to the target lib.
    #
    # If the target is a directory, all files forward of that directory
    # will be copied into the RubyGem.
    # 
    def add_library name, target
      libraries << { :name => name, :target => target }
      files << target
    end

    ##
    # Add an executable to the RubyGem package.
    #
    # @name Symbol that will be used to retrieve this executable later.
    # @target The relative path to the executable that will be associated
    # with this name.
    #
    def add_executable name, target
      executables << { :name => name, :target => target }
      files << target
    end

    def to_s
      "[FileTarget type=#{type} platform=#{platform} files=#{files.inspect}]"
    end

    private

    def cleanup_files files
      new_files = []
      updated = files.flatten
      updated.each do |file|
        if(File.directory?(file))
          new_files.concat FileList["#{file}/**/*"].to_a
        else
          new_files << file
        end
      end
      new_files
    end

  end
end

