require 'test_helper'
require 'fixtures/executable/fdb'

class ExecutableSessionTest < Test::Unit::TestCase
  include Sprout::TestHelper

  context "a new executable session" do

    setup do
      # Uncomment the following to see interactive sessions:
      #Sprout.stdout = $stdout
      #Sprout.stderr = $stderr
    end

    should "execute without shell params" do
      @fdb = Sprout::FDB.new
      @fdb.execute false
      @fdb.run
 
      Kernel.system 'open ~/Projects/Sprouts/flashsdk/test/fixtures/flashplayer/AsUnit\ Runner.swf'

      @fdb.wait_for_prompt
      @fdb.break "AsUnitRunner:12"

      @fdb.continue
      @fdb.continue
      @fdb.quit

      #@fdb.handle_user_input
    end
  end

end


=begin
  context "a new daemon delegate" do

    setup do
      # Uncomment the following to see interactive sessions:
      #Sprout.stdout = $stdout
      #Sprout.stderr = $stderr

      # Comment the following and install the flashsdk
      # to run test against actual fdb:
      insert_fake_executable File.join(fixtures, 'executable', 'flex3sdk_gem', 'fdb')
    end

    should "execute without shell params" do
      @fdb = Sprout::FDB.new
      # For some reason, using mocha expectations are 
      # actually stubbing the methods and breaking this
      # test. Not sure what I'm doing wrong here...
      #@fdb.expects(:execute_action).at_least(6)
      @fdb.run
      @fdb.break "AsUnitRunner:12"
      @fdb.continue
      @fdb.kill
      @fdb.confirm
      @fdb.quit
      @fdb.execute
    end

    should "open and wait for real-time interactions" do
      @fdb = Sprout::FDB.new
      # For some reason, using mocha expectations are 
      # actually stubbing the methods and breaking this
      # test. Not sure what I'm doing wrong here...
      #@fdb.expects(:execute_action).at_least(6)
      @fdb.execute false
      @fdb.run
      @fdb.break "AsUnitRunner:12"
      @fdb.continue
      @fdb.kill
      @fdb.confirm
      @fdb.quit
      @fdb.wait # wait for actions to finish.
    end

    should "print errors" do
      ##
      # Collect the messages sent to stderr:
      
      @fdb = Sprout::FDB.new
      # For some reason, using mocha expectations are 
      # actually stubbing the methods and breaking this
      # test. Not sure what I'm doing wrong here...
      #@fdb.expects(:execute_action).at_least(6)
      @fdb.execute false
      @fdb.run_with_error
      @fdb.quit
      @fdb.wait # wait for actions to finish.

      assert_matches /This is an error!/, Sprout.stderr.read
    end

    should "execute from rake task" do
      f = fdb :fdb_debug do |t|
        t.run
        t.break "AsUnitRunner:12"
        t.continue
        t.kill
        t.confirm
        t.quit
      end

      f.execute

      # NOTE: If this call raises, then the 
      # Executable.update_rake_task_name method 
      # must have changed, and the Daemon override 
      # is no longer preventing non-File tasks 
      # from being added to the CLEAN collection.
      #
      # Adding this as a message to the error would
      # not display for some reason...
      assert_equal 0, CLEAN.size
    end

  end

end
=end

