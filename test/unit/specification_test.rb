require File.dirname(__FILE__) + '/test_helper'

class SpecificationTest < Test::Unit::TestCase
  include SproutTestCase

  context "a newly defined specification" do
    setup do
      @spec = Sprout::Specification.new do |s|
        s.version = '1.0.pre'
      end
    end

    should "have a default name" do
      assert_equal 'specification_test', @spec.name
    end

    should "accept the version" do
      assert_equal '1.0.pre', @spec.version
    end

    context "with a new name" do
      setup do
        @spec.name    = 'foo_sdk'
        @spec.version = '1.0.pre'
      end

      should "register executables" do
        @spec.add_file_target do |t|
          t.add_executable :foo, 'bin/foo'
        end

        Sprout::Executable.stubs :require_ruby_package
        assert_not_nil Sprout::Executable.load :foo, 'foo_sdk', '1.0.pre'
      end

    end
  end

  context "a newly included executable" do
    setup do
      @echo_chamber = File.join fixtures, 'executable', 'echochamber_gem', 'echo_chamber'
      $:.unshift File.dirname(@echo_chamber)
    end

    teardown do
      $:.shift
    end

    should "require the sproutspec" do
      path = Sprout::Executable.load(:echos, 'echo_chamber').path
      assert_matches /fixtures\/.*echochamber/, path
      assert_file path

      # TODO: We should be able to execute
      # the provided executable!
      #response = Sprout::System.create.execute path
      #assert_equal 'ECHO ECHO ECHO', response
    end
  end
end

