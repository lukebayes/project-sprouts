require 'test_helper'

class OSXSystemTest < Test::Unit::TestCase
  include SproutTestCase

  context "new osx system" do

    setup do
      @user = Sprout::System::OSXSystem.new
      @user.stubs(:home).returns '/Users/someone'
    end

    should "capitalize application name" do
      File.stubs(:exists?).returns true
      assert_equal '/Users/someone/Library/Sprouts', @user.application_home('sprouts')
    end

  end
end

