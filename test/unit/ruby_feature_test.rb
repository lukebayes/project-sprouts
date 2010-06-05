require File.dirname(__FILE__) + '/test_helper'

class RubyFeatureTest < Test::Unit::TestCase
  include SproutTestCase

  context "a new ruby feature" do

    teardown do
      FakePlugin.clear_entities!
    end

    should "allow register" do
      FakePlugin.expects :require_ruby_package
      plugin = create_item
      FakePlugin.register plugin
      assert_equal plugin, FakePlugin.load(:foo, 'sprout/base')
    end

    should "return nil if nothing is registered" do
      FakePlugin.expects :require_ruby_package
      assert_raises Sprout::Errors::LoadError do
        FakePlugin.load(:foo, 'sprout/base')
      end
    end

    should "find the correct registered plugin" do
      foo = create_item
      bar = create_item :name => :bar
      FakePlugin.register foo
      FakePlugin.register bar
      assert_equal bar, FakePlugin.load(:bar)
    end

    should "not share registrations among includers" do
      foo = create_item
      FakePlugin.register foo
      assert_raises Sprout::Errors::LoadError do
        OtherFakePlugin.load :foo
      end
    end

    should "allow registration and load without ruby package or version" do
      FakePlugin.register OpenStruct.new({:name => :foo2})
      assert_not_nil FakePlugin.load :foo2
    end
  end

  private

  def create_item options={}
    OpenStruct.new({:name => :foo, :pkg_name => 'sprout/base', :pkg_version => '1.0.pre', :platform => :darwin}.merge(options))
  end

  class FakePlugin
    include Sprout::RubyFeature
  end

  class OtherFakePlugin
    include Sprout::RubyFeature
  end
end 


