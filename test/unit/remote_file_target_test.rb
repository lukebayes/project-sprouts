require File.dirname(__FILE__) + '/test_helper'

class RemoteFileTargetTest < Test::Unit::TestCase
  include SproutTestCase

  context "a remote file target" do

    setup do
      @target = Sprout::RemoteFileTarget.new
      @target.platform = :universal
      @target.add_executable :mxmlc, 'bin/mxmlc'
      @target.add_library :flexsdk, 'lib/flexsdk.swc'
      @target.add_library :airglobals, 'lib/airglobals.swc'
      @target.add_library :playerglobal, 'lib/playerglobals.swc'
    end

    should "have assigned executable" do
      exe = @target.executables.first
      assert_equal :mxmlc, exe[:name]
      assert_equal 'bin/mxmlc', exe[:target]
    end

    should "have assigned libraries" do
      library = @target.libraries.first
      assert_equal :flexsdk, library[:name]
      assert_equal 'lib/flexsdk.swc', library[:target]
    end

  end
end

