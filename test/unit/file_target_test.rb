require File.dirname(__FILE__) + '/test_helper'

class FileTargetTest < Test::Unit::TestCase
  include SproutTestCase

  context "a file target" do

    setup do
      target = Sprout::FileTarget.new
      target.md5 = 'abcd'
      target.platform = :win32
      target.archive_type = :zip
      target.add_executable :mxmlc, 'bin/mxmlc.exe'
      target.add_executable :adl, 'bin/adl.exe'

      @yaml = target.to_yaml
      assert_not_nil @yaml
    end

    should "load from yaml" do
      obj = YAML::load @yaml
      assert_equal 'abcd', obj.md5
      assert_equal :win32, obj.platform
      assert_equal :zip, obj.archive_type
      assert_equal 2, obj.executables.size

      exe = obj.executables[0]
      assert_equal :mxmlc, exe[:name]
      assert_equal 'bin/mxmlc.exe', exe[:target]

      exe = obj.executables[1]
      assert_equal :adl, exe[:name]
      assert_equal 'bin/adl.exe', exe[:target]
    end

  end
end

