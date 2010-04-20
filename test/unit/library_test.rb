require File.dirname(__FILE__) + '/test_helper'

class LibraryTest < Test::Unit::TestCase
  include SproutTestCase

  context "a new embedded library" do
    setup do
      asunit = File.join(fixtures, 'library', 'asunit.rb')
      require asunit
    end

    should "raise on unexpected args" do
      assert_raises Sprout::UsageError do
        class FooClass
          include Sprout::Library
          add_file_target :universal do |t|
            t.add_file_target :a, :b, :c
          end
        end
      end
    end

    should "raise on unknown method" do
      assert_raises Sprout::UsageError do
        class FooClass
          include Sprout::Library
          add_file_target :universal do |t|
            t.unknown_method_call
          end
        end
      end
    end

    should "have exactly one file_target" do
      assert_equal 1, FakeAsUnit.file_targets.size
    end

    should "have exactly two libraries" do
      target = FakeAsUnit.file_targets.first
      assert_equal 2, target.libraries.size
    end

  end

end

