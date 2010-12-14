require 'test_helper'
require 'fixtures/executable/fdb'

class DaemonTest < Test::Unit::TestCase
  include SproutTestCase

  context "a new daemon delegate" do

    setup do
      @fdb = FDB.new
    end

    should "invoke" do
      @fdb.invoke
    end
  end
end

