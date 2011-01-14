require 'test_helper'
require 'fixtures/executable/fdb'

class ExecutableSessionTest < Test::Unit::TestCase
  include Sprout::TestHelper

  context "a new executable session" do

    setup do
      # Uncomment the following to see interactive sessions:
      Sprout.stdout = $stdout
      Sprout.stderr = $stderr
    end

    should "execute without shell params" do
      @fdb = Sprout::FDB.new
      # Comment to hit real FDB:
      #@fdb.binary_path = File.join fixtures, 'executable', 'flex3sdk_gem', 'fdb'

      @fdb.execute false
      @fdb.run
 
      # Uncomment if you are on OSX and want to 
      # test the real FDB while running a real SWF:
      Kernel.system 'open ~/Projects/Sprouts/flashsdk/test/fixtures/flashplayer/AsUnit\ Runner.swf'
      @fdb.wait_for_prompt
      
      @fdb.break "AsUnitRunner:12"

      @fdb.continue
      @fdb.continue

      @fdb.handle_user_input
      #@fdb.quit
    end

  end

end

