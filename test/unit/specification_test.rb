require File.dirname(__FILE__) + '/test_helper'

class SpecificationTest < Test::Unit::TestCase
  include SproutTestCase

  context "a new specification" do

    setup do
      @fixture = File.expand_path(File.join(fixtures, 'specification'))
      @asunit_spec = File.join @fixture, 'asunit4.sproutspec'
      @flexsdk_spec = File.join @fixture, 'flex4sdk.sproutspec'
    end

    context "with unexpected configuration param" do
      context "on spec" do
        should "fail " do
          assert_raises NoMethodError do
            Sprout::Specification.new do |s|
              s.unknown_parameter = 'bad value'
            end
          end
        end
      end

      context "on file_target" do
        should "fail " do
          assert_raises NoMethodError do
            Sprout::Specification.new do |s|
              s.add_file_target do |t|
                t.unknown_parameter = 'bad value'
              end
            end
          end
        end
      end

      context "on remote_file_target" do
        should "fail " do
          assert_raises NoMethodError do
            Sprout::Specification.new do |s|
              s.add_remote_file_target do |t|
                t.unknown_parameter = 'bad value'
              end
            end
          end
        end
      end
    end

    should "load a complex configuration without error" do
      spec = Sprout::Specification.load @flexsdk_spec
      spec.stubs(:register_remote_file_targest)
      assert spec.is_a?(Sprout::Specification)
      assert_equal 'flex4sdk', spec.name
      assert_equal '4.0.pre', spec.version
      assert_equal 2, spec.remote_file_targets.size
    end

  end
end

