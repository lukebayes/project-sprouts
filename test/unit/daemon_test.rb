require 'test_helper'
require 'fixtures/executable/fdb'

class DaemonTest < Test::Unit::TestCase
  include SproutTestCase

  context "a new daemon delegate" do

    setup do
      # Uncomment to see actual output:
      #Sprout::Log.debug = false

      @fdb = Sprout::FDB.new
      configure_fdb_path
    end

    should "execute without shell params" do
      @fdb.run
      @fdb.break "AsUnitRunner:12"
      @fdb.continue
      @fdb.kill
      @fdb.confirm
      @fdb.quit
      @fdb.execute
    end

  end

  private

  def configure_fdb_path
    @fdb_fake = File.join(fixtures, 'executable', 'flex3sdk_gem', 'fdb')
    # Comment the following and install the flashsdk
    # to run test against actual fdb:
    path_response = OpenStruct.new(:path => @fdb_fake)
    Sprout::Executable.expects(:load).with(:fdb, 'flex4', '>= 4.1.0.pre').returns path_response
  end
end

