require File.dirname(__FILE__) + '/test_helper'

class StringTest < Test::Unit::TestCase
  include SproutTestCase

  context "a new string" do

    should "switch to snake case" do
      assert_equal "a_b_c", "ABC".snake_case
      assert_equal "my_big_camel_case_word", "MyBigCamelCaseWord".snake_case
    end

    should "switch to camel case" do
      assert_equal "ABC", "a_b_c".camel_case
      assert_equal "MyBigCamelCaseWord", "my_big_camel_case_word".camel_case
    end

  end
end

