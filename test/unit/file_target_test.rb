require 'test_helper'

class FileTargetTest < Test::Unit::TestCase
  include Sprout::TestHelper

  context "a file target" do
    setup do
      @asunit_swc = 'bin/AsUnit4-4.1.pre.swc'
    end

    context "that is created with a constructor block" do
      should "have the provided values" do
        target = Sprout::FileTarget.new do |t|
          t.pkg_name    = 'asunit4'
          t.pkg_version = '4.2.2.pre'
          t.add_library :swc, @asunit_swc
        end
        assert_provided_values target
      end
    end

    context "that is created with no constructor block" do
      should "have the provided values" do
        target = Sprout::FileTarget.new
        target.pkg_name    = 'asunit4'
        target.pkg_version = '4.2.2.pre'
        target.add_library :swc, @asunit_swc
        assert_provided_values target
      end
    end

  end

  private

  def assert_provided_values t
    assert_equal :universal, t.platform
    assert_equal 0, t.executables.size
    assert_equal 1, t.libraries.size
    library = t.libraries.first
    assert_equal :swc, library.name
    assert_equal File.join('.', @asunit_swc), library.path
    assert_equal '[FileTarget pkg_name=asunit4 pkg_version=4.2.2.pre platform=universal]', t.to_s
  end

end

