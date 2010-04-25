
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
  # basically nothing in our tool chain is open source.
  #
  # Even the Flex SDK - which you may have heard is, "Open Source",
  # has a license that restricts our ability to redistribute it.
  #
  # This restriction means that many of our tools and dependencies cannot be 
  # packaged and distributed _directly_ within a RubyGem (or from
  # any server other than Adobe's as a matter of fact).
  #
  # In order to overcome this restriction, we have introduced
  # a new Specification format that delegates most of it's work
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

