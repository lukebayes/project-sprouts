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
        @spec.name = 'fake_spec'
      end

      should "register executables" do
        @spec.add_file_target do |t|
          t.add_executable :foo, 'bar'
        end

        assert_equal 1, Sprout.executables.size
      end

    end
  end

=begin
  context "a newly loaded specification" do

    setup do
      @fixture = File.expand_path(File.join(fixtures, 'specification'))
      @flexsdk_spec = File.join @fixture, 'flex4sdk.rb'
    end

    should "update Sprout.executables" do
      load @flexsdk_spec
      assert_equal 13, Sprout.executables.size
    end

  end
=end

  context "a newly included tool" do

    setup do
      @echo_chamber = File.join fixtures, 'tool', 'echochamber_gem', 'echo_chamber'
    end

    should "require the sproutspec" do
      assert_equal 0, Sprout.executables.size
      path = Sprout.load_executable :echos, @echo_chamber
      assert_matches /fixtures\/.*echochamber/, path
      assert_file path

      # TODO: We should be able to execute
      # the provided executable!
      #response = Sprout::User.create.execute path
      #assert_equal 'ECHO ECHO ECHO', response
    end
  end
end

