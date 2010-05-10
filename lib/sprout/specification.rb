
module Sprout

  ##
  # Sprouts provides us with the ability to distribute source files, 
  # precompiled libraries, and remote executables. It does all of 
  # this by (ab)using RubyGems.
  #
  # RubyGems gives us the ability to version-manage, and distribute 
  # arbitrary text and binary payloads.
  #
  # In order to support Flash development, we have one major problem
  # that RubyGems does not solve for us. This is the fact that 
  # many elements of our tool chain are not open-source, and we do
  # not have the rights to directly distribute them.
  #
  # This restriction means that many of our tools and dependencies cannot be 
  # packaged and distributed _directly_ within a RubyGem (or from
  # any server other than Adobe's as a matter of fact).
  #
  # In order to overcome this restriction, we have introduced
  # a Sprout::Specification. This is a regular Ruby file with regular
  # Ruby code in it. The main idea behind this file, is that it
  # needs to be given a name and available in your load path.
  #
  # Whenever a rake build task (Sprout::Tool) or library task,
  # (Sprout::Library) is encountered, it will call
  # Sprout.load_executable or Sprout.get_library (respectively).
  #
  # These methods will attempt to +require+ the provided
  # specification and - if it's in your load path - the specification
  # will be loaded, and any relevant file targets will be returned.
  #
  # There are many ways to get Ruby code into your load path.
  # One of the easiest to package it up in a RubyGem and
  # configure the +require_paths+ parameter of  your Gem::Specification.
  #
  # http://docs.rubygems.org/read/chapter/20#require_paths
  #
  # To learn more about packaging RubyGems:
  #
  # http://docs.rubygems.org/read/chapter/20#page85
  # http://rubygems.rubyforge.org/rdoc/Gem/Specification.html
  #
  # To learn more about published RubyGems:
  # 
  # http://rubygems.org/pages/gem_docs
  #
  # To package a SWC library into a Sprout RubyGem, you would create a file (usually)
  # named [project_name.spec] in the root of the project.
  #
  # This is your Gem::Specification.
  #
  # You would also create a file named [projet_name.sproutspec] and put that
  # into the root of the project or some other folder that you have added to 
  # the Gem::Specification.require_paths parameter.
  #
  # == Example: Include a file directly in the RubyGem
  #
  # In the case of AsUnit, this file would be named asunit4.sproutspec and it's contents
  # are as follows:
  #
  #    :include:../../test/fixtures/specification/asunit4.sproutspec
  #
  # == Example: Refer to files that are not in the RubyGem
  #
  # For projects like the Flex SDK, we can't distribute many of the required files,
  # so we can refer to these files in our Sprout::Specification as +remote_file_targets+.
  #
  #    :include:../../test/fixtures/specification/flex4sdk.sproutspec
  #
  # == Example: Create custom downloads for each supported platform
  #
  # For projects like the Flash Player itself, we need to refer to different 
  # downloadable content for each supported platform.
  #
  #    :include:../../test/fixtures/specification/flashplayer.sproutspec
  #
  # == Packaging and Sharing
  #
  # Public RubyGems are hosted at http://rubygems.org. 
  class Specification

    # Class Methods:
    class << self

      # Load an arbitrary file with a single
      # Sprout::Specification declared in it.
      def load filename
        data = File.read filename
        eval data, nil, filename
      end
    end

    attr_accessor :name
    attr_accessor :version
    attr_accessor :files

    attr_reader :remote_file_targets
    attr_reader :file_targets

    # Create a new Sprout::Specification.
    #
    # This method will yield the new Sprout::Specification to the provided block,
    # and delegate most configuration parameters to a {Gem::Specification}[http://rubygems.rubyforge.org/rdoc/Gem/Specification.html].
    #
    # To learn more about what parameters are available and/or required, please
    # check out RubyGems documentation for their {Gem::Specification}[http://rubygems.rubyforge.org/rdoc/Gem/Specification.html].
    #
    def initialize
      initialize_members
      yield self if block_given?
      post_initialize
    end

    # Add a remote file target to this RubyGem so that when it
    # is installed, Sprouts will go fetch this file from the network.
    #
    # Each time this method is called, a new Sprout::RemoteFiletarget instance will be yielded to
    # the provided block and added to a collection for packaging.
    #
    def add_remote_file_target &block
      @remote_file_targets << RemoteFileTarget.new(&block)
    end

    # Add a file to the RubyGem itself. This is a great way to package smallish libraries in either
    # source or already-packaged form. For example, one might add a SWC to a RubyGem library.
    # 
    # Each time this method is called, a new Sprout::FileTarget instance will be yielded to the
    # provided block, and added to a collection for packaging.
    #
    #     Sprout::Specification.new do |s|
    #        ...
    #        s.add_file_target do |t|
    #            t.name = :swc
    #            t.files = ["bin/AsUnit-4.1.pre.swc"]
    #        end
    #     end
    #
    def add_file_target &block
      @file_targets << FileTarget.new(&block)
    end

    private

    def initialize_members
      @files               = []
      @file_targets        = []
      @remote_file_targets = []
    end

    def post_initialize
      # TODO: the included 'files' should get modified by the following expressions:
      #included_files = FileList["**/*"].exclude /.DS_Store|generated|.svn|.git|airglobal.swc|airframework.swc/
      register_file_targets
      register_remote_file_targets
    end

    private

    def register_file_targets
      file_targets.each do |target|
        target.pkg_name    = name
        target.pkg_version = version
        register_file_target target
      end
    end

    def register_remote_file_targets
      #puts "resolve remotes: #{remote_file_targets.size}"
      remote_file_targets.each do |target|
        register_remote_file_target target
      end
    end

    def register_remote_file_target target
      target.pkg_name    = name
      target.pkg_version = version
      #target.resolve
      #register_file_target target
    end

    def register_file_target target
      target.executables.each do |exe|
        register_executable exe
      end

      target.libraries.each do |lib|
        # register_library lib
      end
    end

    def register_executable exe
      Sprout.register_executable exe
    end

    def register_library lib
      # Sprout.register_library lib
    end

  end
end

