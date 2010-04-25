
require 'delegate'

module Sprout

  ##
  # Sprouts provides us with the ability to distribute source files, 
  # precompiled libraries, and remote executables. It does all of 
  # this by (ab)using RubyGems.
  #
  # It just so happens that RubyGems gives us the ability to
  # version-manage, and distribute arbitrary payloads.
  #
  # In order to support Flash development, we have one major problem
  # that RubyGems does not solve for us. This is the fact that 
  # basically nothing in our tool chain is open source.
  #
  # Even the Flex SDK - which you may have heard is, "Open Source",
  # has a license that restricts our ability to redistribute it.
  #
  # This restriction means that many of our tools and dependencies cannot be 
  # packaged and distributed _directly_ within a RubyGem.
  #
  # In order to overcome this restriction, we have introduced
  # a new 
  #
  #
  #
  #
  # In order to create the RubyGem, one would simply cd to the
  # folder that has this specification file, and run:
  #
  #     gem build asunit4.gemspec
  #
  # Then, to release the gem to the public, simply run:
  #
  #     gem push asunit4-4.2.pre.gem
  #
  # To learn more about packaging RubyGems:
  #
  #     http://docs.rubygems.org/read/chapter/20#page85
  #     http://rubygems.rubyforge.org/rdoc/Gem/Specification.html
  #
  # To learn more about published RubyGems:
  # 
  #     http://rubygems.org/pages/gem_docs
  #
  class Specification < DelegateClass(Gem::Specification)

    attr_accessor :file_target

    def initialize
      @gem_specification = Gem::Specification.new
      super(@gem_specification)
      @gem_specification.required_rubygems_version = '>= 1.3.6'

      yield self if block_given?

      # TODO: the included 'files' should get modified by the following expressions:
      #included_files = FileList["**/*"].exclude /.DS_Store|generated|.svn|.git|airglobal.swc|airframework.swc/
      
      self.files = [file_target]
    end

    def files=(files)
      @gem_specification.files = files
    end

    def files
      @gem_specification.files ||= []
    end

  end
end

