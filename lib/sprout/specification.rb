
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
  # many elements of our executable chain are not open-source, and we do
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
  # Whenever a rake build task (Sprout::Executable) or library task,
  # (Sprout::Library) is encountered, it will call
  # Sprout::Executable.load or Sprout::Library.load (respectively).
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
  # You would also create a file named [projet_name.rb] and put that
  # into the root of the project or some other folder that you have added to
  # the Gem::Specification.require_paths parameter.
  #
  # == Example: Include a file directly in the RubyGem
  #
  # In the case of AsUnit, this file would be named asunit4.rb and it's contents
  # are as follows:
  #
  #    :include:../../test/fixtures/specification/asunit4.rb
  #
  # == Example: Refer to files that are not in the RubyGem
  #
  # For projects like the Flex SDK, we can't distribute many of the required files,
  # so we can refer to these files in our Sprout::Specification as +remote_file_targets+.
  #
  #    :include:../../test/fixtures/specification/flex4sdk.rb
  #
  # == Example: Create custom downloads for each supported platform
  #
  # For projects like the Flash Player itself, we need to refer to different
  # downloadable content for each supported platform.
  #
  #    :include:../../test/fixtures/specification/flashplayer.rb
  #
  # == Packaging and Sharing
  #
  # Public RubyGems are hosted at http://rubygems.org.
  class Specification

    attr_accessor :name
    attr_accessor :version

    attr_reader :file_targets
    attr_reader :load_path

    ##
    # Create a new Sprout::Specification.
    #
    # This method will yield the new Sprout::Specification to the provided block,
    # and delegate most configuration parameters to a {Gem::Specification}[http://rubygems.rubyforge.org/rdoc/Gem/Specification.html].
    #
    # To learn more about what parameters are available and/or required, please
    # check out RubyGems documentation for their {Gem::Specification}[http://rubygems.rubyforge.org/rdoc/Gem/Specification.html].
    #
    def initialize
      filename   = Sprout.file_from_caller caller.first
      @load_path = File.dirname filename
      @name      = File.basename(filename).gsub('.rb', '')
      yield self if block_given?
    end

    ##
    # Add a remote file target to this RubyGem so that when it
    # is loaded, Sprouts will go fetch this file from the network.
    #
    # Each time this method is called, a new Sprout::RemoteFiletarget instance will be yielded to
    # the provided block and resolved after the block completes.
    #
    # After this block is evaluated, Sprouts will first check the collection
    # of env_names to see if the expected paths are available. If a valid
    # env_name is found, Sprouts will return the path to the requested
    # executable from the environment variable.
    #
    # If no env_names are set, or the requested executable is not found within
    # any that are identified, Sprouts will check to see if the archive
    # has already been unpacked into the expected location:
    #
    #     #{SPROUT_HOME}/cache/#{SPROUT_VERSION}/flex4sdk/#{md5}/4.0.pre
    #
    # If the archive been unpacked, Sprouts will return the path to the
    # requested executable.
    #
    # If the archive has not been unpacked, Sprouts will check to see if the
    # archive has been downloaded to:
    #
    #     #{SPROUT_HOME}/cache/#{SPROUT_VERSION}/flex4sdk/#{md5}.zip
    #
    # If the archive has been downloaded, it will be unpacked and the path
    # to the requested executable will be returned.
    #
    # If the archive has not been downloaded, it will be downloaded, unpacked
    # and the path to the requested executable will be returned.
    def add_remote_file_target &block
      target = RemoteFileTarget.new
      configure_target target, &block
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
    #           t.platform = :universal
    #           t.add_executable :asdoc, 'bin/asdoc'
    #        end
    #     end
    #
    def add_file_target &block
      target = FileTarget.new
      configure_target target, &block
    end

    private

    def configure_target t, &block
      t.load_path   = load_path
      t.pkg_name    = name
      t.pkg_version = version
      yield t if block_given?
      register_file_target_libs_and_exes t
    end

    def register_file_target_libs_and_exes target
      register_items target.executables, Sprout::Executable, target
      # Reversing the libraries makes it so that definitions like:
      #
      #   target.add_library :swc, 'abcd'
      #   target.add_library :src, 'efgh'
      #
      # When loading, if no name is specified, the :swc will be
      # returned to clients.
      register_items target.libraries, Sprout::Library, target
    end

    def register_items collection, ruby_feature, target
      collection.each do |exe_or_lib|
        exe_or_lib.pkg_name    = target.pkg_name
        exe_or_lib.pkg_version = target.pkg_version
        exe_or_lib.platform    = target.platform
        exe_or_lib.file_target = target
        ruby_feature.register exe_or_lib
      end
    end

  end
end

