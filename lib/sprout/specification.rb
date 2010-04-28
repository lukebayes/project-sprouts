
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
  # to RubyGem's Gem::Specification, but adds some features
  # that make it possible for us to refer directly to bundled
  # content, and refer to remote packages of content.
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
      initialize_members
      super(@gem_specification)
      @gem_specification.required_rubygems_version = '>= 1.3.6'
      yield self if block_given?
      # TODO: the included 'files' should get modified by the following expressions:
      #included_files = FileList["**/*"].exclude /.DS_Store|generated|.svn|.git|airglobal.swc|airframework.swc/
    end

    def add_remote_file_target
    end

    def add_file_target
      target = FileTarget.new
      @file_targets << target
    end

    private

    def initialize_members
      @file_targets        = []
      @remote_file_targets = []
      @gem_specification   = Gem::Specification.new
    end

  end
end

