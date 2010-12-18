require 'test_helper'
#require 'fixtures/executable/fdb_buffer'
require 'fixtures/executable/fdb'

class DaemonTest < Test::Unit::TestCase
  include SproutTestCase

  context "a new daemon delegate" do

    setup do
      @fdb = Sprout::FDB.new
      configure_fdb_path
    end

    should "execute without shell params" do
      @fdb.run
      @fdb.break "SomeFile.as:34"
      @fdb.continue
      @fdb.next
      @fdb.next

      @fdb.execute
    end

  end

  private

  def configure_fdb_path
    @fdb_fake = File.join(fixtures, 'executable', 'flex3sdk_gem', 'fdb')
    #path_response  = OpenStruct.new(:path => @fdb_fake)
    #Sprout::Executable.expects(:load).with(:fdb, 'flex4sdk', '>= 1.0.0.pre').returns path_response
  end
end

