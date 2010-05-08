require 'delegate'

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
  # many elements of our tool chain are not open-source.
  #
  # Even the Flex SDK (as of version 4.x) which you may have heard is, "Open Source",
  # has a license that restricts our ability to redistribute it.
  #
  # This restriction means that many of our tools and dependencies cannot be 
  # packaged and distributed _directly_ within a RubyGem (or from
  # any server other than Adobe's as a matter of fact).
  #
  # In order to overcome this restriction, we have introduced
  # a new Specification format that delegates most of its work
  # to RubyGem's {Gem::Specification}[http://rubygems.rubyforge.org/rdoc/Gem/Specification.html], but adds some features
  # that make it possible for us to refer directly to bundled
  # content, and refer to remote packages of content.
  #
  # To learn more about packaging RubyGems:
  #
  # http://docs.rubygems.org/read/chapter/20#page85
  #
  # http://rubygems.rubyforge.org/rdoc/Gem/Specification.html
  #
  # To learn more about published RubyGems:
  # 
  # http://rubygems.org/pages/gem_docs
  #
  # To package a SWC library into a Sprout RubyGem, you would create a file (usually)
  # named [project_name.spec] in the root of the project.
  #
  # == Example: Include a file directly in the RubyGem
  #
  # In the case of AsUnit, this file would be named asunit4.spec and it's contents
  # are as follows:
  #
  #    :include:../../test/fixtures/specification/asunit4.spec
  #
  # == Example: Refer to files that are not in the RubyGem
  #
  # For projects like the Flex SDK, we can't distribute many of the required files,
  # so we can refer to these files in our Sprout::Specification as +remote_file_targets+.
  #
  #    :include:../../test/fixtures/specification/flex4sdk.spec
  #
  # == Example: Create custom downloads for each supported platform
  #
  # For projects like the Flash Player itself, we need to refer to different 
  # downloadable content for each supported platform.
  #
  #    :include:../../test/fixtures/specification/flashplayer.spec
  #
  #
  # == Packaging and Sharing
  #
  # Public RubyGems are hosted at http://rubygems.org. 
  #
  # If you create a Sprout::Specification, you can build a
  # gem and push it to any gem host (by default rubygems.org).
  #
  # Assuming you have a spec named, +asunit4.spec+, you could
  # do the following to package and publish that RubyGem:
  #
  #    gem build asunit4.spec # The file you write
  #    gem push asunit4-4.1.pre.gem # The file that was built
  #
  class Specification < DelegateClass(Gem::Specification)

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
      super(@gem_spec)
      initialize_gem_spec_members
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
      @file_targets        = []
      @remote_file_targets = []
      @gem_spec            = Gem::Specification.new
    end

    def initialize_gem_spec_members
      @gem_spec.rubyforge_project = 'sprout'
      @gem_spec.add_dependency 'sprout', '>= 1.0.pre'
    end

    def post_initialize
      # TODO: the included 'files' should get modified by the following expressions:
      #included_files = FileList["**/*"].exclude /.DS_Store|generated|.svn|.git|airglobal.swc|airframework.swc/
      added = []
      @file_targets.each do |target|
        added << target.files
      end
      added.flatten!
      self.files = added
    end

  end
end

