require 'test_helper'

class StringParamTest < Test::Unit::TestCase
  include Sprout::TestHelper

  context "a new StringParam" do

    setup do
      @param = Sprout::Executable::StringParam.new
      @param.name = "string"
    end

    should "escape spaces" do
      @param.value = "a b c"
      assert_equal '--string=a\ b\ c', @param.to_shell
    end
  end
end

