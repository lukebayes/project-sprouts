require File.dirname(__FILE__) + '/test_helper'

class OSXUserTest < Test::Unit::TestCase
  include SproutTestCase

  context "new osx user" do

    setup do
      @user = Sprout::User::OSXUser.new
      @user.stubs(:home).returns '/Users/someone'
    end

    should "capitalize application name" do
      File.stubs(:exists?).returns true
      assert_equal '/Users/someone/Library/Sprouts', @user.application_home('sprouts')
    end

  end
end
