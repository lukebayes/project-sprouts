require File.dirname(__FILE__) + '/test_helper'

class RemoteFileLoaderTest <  Test::Unit::TestCase
  include SproutTestCase

  context "The remote file loader" do

    setup do
      @uri  = 'http://github.com/downloads/lukebayes/project-sprouts/echochamber-test.zip'
      @file = File.join fixtures, 'remote_file_loader', 'md5', 'echochamber-test.zip'
      @md5  = 'd6939117f1df58e216f365a12fec64f9'

      # Don't reach out to the network for these tests:
      Sprout::RemoteFileLoader.stubs(:fetch).returns File.read @file
    end

    should "attempt to load a requested file" do
      bytes = Sprout::RemoteFileLoader.load @uri, @md5
      assert_equal 310, bytes.size
    end

    should "fail if md5 doesn't match" do
      Sprout::RemoteFileLoader.expects(:prompt_for_md5_failure)
      Sprout::RemoteFileLoader.load @uri, 'abcd'
    end

    should "pass if md5 isn't provided" do
      Sprout::RemoteFileLoader.expects(:prompt_for_md5_failure).never
      Sprout::RemoteFileLoader.load @uri
    end
  end

end

