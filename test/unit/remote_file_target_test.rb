require File.dirname(__FILE__) + '/test_helper'

class RemoteFileTargetTest < Test::Unit::TestCase
  include SproutTestCase

  context "a remote file target" do

    setup do
      target = Sprout::RemoteFileTarget.new
      target.type = 'abcd'
      @yaml = target.to_yaml
      assert_not_nil @yaml
    end

    should "load from yaml" do
      obj = YAML::load @yaml
      assert_equal 'abcd', obj.type
    end

  end
end

