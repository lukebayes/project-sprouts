require 'test_helper'

class RubyFeatureTest < Test::Unit::TestCase
  include Sprout::TestHelper

  context "a new ruby feature" do

    teardown do
      FakePlugin.clear_entities!
    end

    should "allow register" do
      # Shouldn't require the package since it's already
      # registered and available...
      FakePlugin.expects(:require_ruby_package).never
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

    should "not call resolve on register" do
      plugin = FakePlugin.new({:name => :foo2})
      plugin.expects(:resolve).never
      FakePlugin.register plugin
    end

    should "call resolve on load" do
      plugin = FakePlugin.new({:name => :foo2})
      FakePlugin.register plugin

      plugin.expects(:resolve)
      FakePlugin.load :foo2
    end

    should "allow registration and load without ruby package or version" do
      FakePlugin.register FakePlugin.new({:name => :foo2})
      assert_not_nil FakePlugin.load :foo2
    end

    should "allow registration and match with nil pkg_name" do
      FakePlugin.register(create_item(:pkg_name => nil))
      assert_not_nil FakePlugin.load :foo
    end

    should "allow registration and match with nil pkg_version" do
      FakePlugin.register(create_item(:pkg_version => nil))
      assert_not_nil FakePlugin.load :foo
    end

    should "allow registration and match with nil platform" do
      FakePlugin.register(create_item(:platform => nil))
      assert_not_nil FakePlugin.load :foo
    end

    should "not allow registration with nil name" do
      assert_raises Sprout::Errors::UsageError do
        FakePlugin.register(create_item(:name => nil))
      end
    end

    should "load when request is a string" do
      FakePlugin.register(FakePlugin.new({:name => :foo3}))
      assert_not_nil FakePlugin.load 'foo3'
    end

    should "load when registration is a string" do
      FakePlugin.register(FakePlugin.new({:name => :swc, :pkg_name => 'asunit4'}))
      assert_not_nil FakePlugin.load nil, :asunit4
    end

    should "raise on failure to find from collection" do
      FakePlugin.register(create_item)
      assert_raises Sprout::Errors::LoadError do
        FakePlugin.load [:bar, :baz]
      end
    end

    should "allow load with collection of names" do
      FakePlugin.register(create_item)
      assert_not_nil FakePlugin.load [:bar, :baz, :foo]
    end

    should "find platform-specific remote file target" do
      osx = create_item(:platform => :osx)
      windows = create_item(:platform => :windows)
      linux = create_item(:platform => :linux)

      FakePlugin.register osx
      FakePlugin.register windows
      FakePlugin.register linux

      as_a_mac_system do
        result = FakePlugin.load :foo
        assert_equal osx, result
      end

      as_a_windows_system do
        result = FakePlugin.load :foo
        assert_equal windows, result
      end

      as_a_win_nix_system do
        result = FakePlugin.load :foo
        assert_equal windows, result
      end

      as_a_unix_system do
        result = FakePlugin.load :foo
        assert_equal linux, result
      end
    end

  end

  private

  def create_item options={}
    FakePlugin.new({:name => :foo, :pkg_name => 'sprout/base', :pkg_version => '1.0.pre', :platform => :universal}.merge(options))
  end

  class FakePlugin < OpenStruct
    include Sprout::RubyFeature

    ##
    # Implement resolve like RemoteFileTargets..
    def resolve
    end
  end

  class OtherFakePlugin
    include Sprout::RubyFeature
  end
end


