require 'test_helper'
require 'fixtures/executable/fdb'

class DaemonTest < Test::Unit::TestCase
  include Sprout::TestHelper

  context "a new daemon delegate" do

    setup do
      # Uncomment to see actual output:
      #Sprout::Log.debug = false
      configure_fdb_fake
    end

    should "execute without shell params" do
      @fdb = Sprout::FDB.new

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
      @fdb.execute false
      @fdb.expects(:execute_action).at_least(6)

      @fdb.run
      @fdb.break "AsUnitRunner:12"
      @fdb.continue
      @fdb.kill
      @fdb.confirm
      @fdb.quit
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

  private

  def configure_fdb_fake
    # Comment the following and install the flashsdk
    # to run test against actual fdb:
    @fdb_fake = File.join(fixtures, 'executable', 'flex3sdk_gem', 'fdb')
    path_response = OpenStruct.new(:path => @fdb_fake)
    Sprout::Executable.expects(:load).with(:fdb, 'flex4', '>= 4.1.0.pre').returns path_response
  end
end

