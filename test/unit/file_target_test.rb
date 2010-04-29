require File.dirname(__FILE__) + '/test_helper'

class FileTargetTest < Test::Unit::TestCase
  include SproutTestCase

  def setup
    super
    @asunit_swc = 'bin/AsUnit4-4.1.pre.swc'
  end

  def assert_provided_values t
    assert_equal :universal, t.platform
    assert_equal :swc, t.type
    assert_equal @asunit_swc, t.files[0]
  end

  def assert_yaml t
    yaml = t.to_yaml
    assert_matches yaml, /platform/
    assert_matches yaml, /universal/
    assert_matches yaml, /type/
    assert_matches yaml, /swc/
    assert_matches yaml, /files/
    assert_matches yaml, /AsUnit/
  end

  context "a file target created with a constructor block" do

    should "have the provided values" do
      target = Sprout::FileTarget.new do |t|
        t.type = :swc
        t.files << @asunit_swc
      end

      assert_provided_values target
      assert_yaml target
    end
  end

  context "a file target created with no constructor block" do

    should "have the provided values" do
      target = Sprout::FileTarget.new
      target.type = :swc
      target.files << @asunit_swc

      assert_provided_values target
      assert_yaml target
    end
  end

end

