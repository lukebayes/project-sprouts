require File.dirname(__FILE__) + '/test_helper'

require 'rubygems/installer'

class LibraryTest < Test::Unit::TestCase
  include SproutTestCase

  context "a new embedded library" do

    setup do
      @asunit_gemspec = File.join(fixtures, 'library', 'asunit.gemspec')
    end

    should "still work with Gem::Builder" do
      spec = Gem::Specification.load @asunit_gemspec

      #builder = Gem::Builder.new spec
      #file = builder.build

      #installer = Gem::Installer.new(file)
      #installed_spec = installer.install

      #uninstaller = Gem::Uninstaller.new(file)
      #uninstaller.uninstall
    end

  end
end

