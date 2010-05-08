require File.dirname(__FILE__) + '/test_helper'

class SpecificationTest < Test::Unit::TestCase
  include SproutTestCase

  context "a new specification" do

    setup do
      @fixture = File.expand_path(File.join(fixtures, 'specification'))

      @asunit_spec = File.join(@fixture, 'asunit4.spec')
      @asunit_gem = File.join(@fixture, "asunit4-4.2.pre.gem")

      @flexsdk_spec = File.join(@fixture, 'flex4sdk.spec')
      @flexsdk_gem = File.join(@fixture, 'flex4sdk-4.0.pre.gem')

      Dir.chdir @fixture
    end

    teardown do
      remove_file @asunit_gem
      remove_file @flexsdk_gem
    end

    should "depend on sprout-1.0.pre" do
      spec = Gem::Specification.load @asunit_spec
      assert_equal 1, spec.runtime_dependencies.size
      dependency = spec.runtime_dependencies[0]
      assert_equal 'sprout', dependency.name
      assert_equal '>= 1.0.pre', dependency.requirement.to_s
    end

    should "fail with unexpected configuration param" do
      assert_raises NoMethodError do
        Sprout::Specification.new do |s|
          s.add_file_target do |t|
            t.unknown_parameter = 'bad value'
          end
        end
      end
    end

    should "have the added files" do
      spec = Gem::Specification.load @asunit_spec
      files = spec.files.dup
      assert_equal 3, files.size
      assert_equal 'src/AsUnit.as', files.shift
      assert_equal 'lib/as3reflection/Reflection.as', files.shift
      assert_equal 'ext/AsUnit-4.1.pre.swc', files.shift
    end

    context "that is packaged with rubygems" do

      setup do
        use_ui @mock_gem_ui do
          spec    = Gem::Specification.load @asunit_spec
          builder = Gem::Builder.new spec
          builder.build

          spec    = Gem::Specification.load @flexsdk_spec
          builder = Gem::Builder.new spec
          builder.build
        end
      end

      should "fail with unexpected configuration param" do
        assert_raises NoMethodError do
          Sprout::Specification.new do |s|
            s.add_remote_file_target do |t|
              t.unknown_parameter = 'bad value'
            end
          end
        end
      end

      should "build the gem archive" do
        assert_file @asunit_gem
        assert_file @flexsdk_gem
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

