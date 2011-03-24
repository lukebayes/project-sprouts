require 'test_helper'
require 'fixtures/executable/fdb'

class ExecutableSessionTest < Test::Unit::TestCase
  include Sprout::TestHelper

  context "a new executable session" do

    setup do
      # Uncomment the following to see interactive sessions:
      #Sprout.stdout = $stdout
      #Sprout.stderr = $stderr
      @test_result_file = File.join fixtures, 'executable', 'Result.xml'
    end

    teardown do
      remove_file @test_result_file
    end

    should "execute without shell params" do
      @fdb = Sprout::FDB.new
      # Comment to hit real FDB:
      @fdb.binary_path = File.join fixtures, 'executable', 'flex3sdk_gem', 'fdb'
      @fdb.test_result_file = @test_result_file

      @fdb.execute false
      @fdb.run
 
      # Uncomment if you are on OSX and want to 
      # test the real FDB while running a real SWF:
      #Kernel.system 'open ~/Projects/Sprouts/flashsdk/test/fixtures/flashplayer/AsUnit\ Runner.swf'
      #@fdb.wait_for_prompt
      
      @fdb.break "AsUnitRunner:12"

      @fdb.continue
      #@fdb.continue

      #@fdb.handle_user_input
      @fdb.quit

      assert_file @test_result_file do |content|
        assert_match content, /Fake Content/
      end
    end

  end

end

