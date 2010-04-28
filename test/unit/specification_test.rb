require File.dirname(__FILE__) + '/test_helper'

class SpecificationTest < Test::Unit::TestCase
  include SproutTestCase

  context "a new specification" do

    setup do
      @fixture = File.expand_path(File.join(fixtures, 'specification'))
      @asunit_gemspec = File.join(@fixture, 'asunit.gemspec')
      @asunit_gem = File.join(@fixture, "asunit-4.2.pre.gem")
      Dir.chdir @fixture
    end

    teardown do
      remove_file @asunit_gem
    end

    context "that is packaged with rubygems" do

      setup do
        use_ui @mock_gem_ui do
          spec    = Gem::Specification.load @asunit_gemspec
          builder = Gem::Builder.new spec
          builder.build
        end
      end

      should "build the gem archive" do
          assert_file @asunit_gem
      end

      should "include sprout.spec" do
      end

      # TODO: unpack and verify contents of gem archive
      #should "include specified contents at ext/AsUnit.swc" do
      #end

      # TODO: Should we actually install to a fixture path?
      #installer = Gem::Installer.new(file)
      #installed_spec = installer.install

      #uninstaller = Gem::Uninstaller.new(file)
      #uninstaller.uninstall
    end
  end
end

