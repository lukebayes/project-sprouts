require File.dirname(__FILE__) + '/test_helper'

class FileTargetTest < Test::Unit::TestCase
  include SproutTestCase

  context "a file target" do

    setup do
      target = Sprout::FileTarget.new
      target.name = 'abcd'
      @yaml = target.to_yaml
      assert_not_nil @yaml
    end

    should "load from yaml" do
      obj = YAML::load @yaml
      assert_equal 'abcd', obj.name
    end

  end
end

