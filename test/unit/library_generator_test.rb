require 'test_helper'
require 'sprout/generators/library/library_generator'

class LibraryGeneratorTest < Test::Unit::TestCase
  include Sprout::TestHelper

  context "A generated library" do

    setup do
      @temp = File.join(fixtures, 'generators', 'library')
      FileUtils.mkdir_p @temp
      @generator = Sprout::LibraryGenerator.new
      @generator.path = @temp
      @generator.logger = StringIO.new
    end

    teardown do
      remove_file @temp
    end

    should "generate a new library" do
      @generator.input = 'flexunit'
      @generator.version = '4.2.pre'
      @generator.execute

      assert_file File.join(@temp, 'flexunit.gemspec') do |content|
        assert_matches /s.name\s+= Flexunit::NAME/, content
        assert_matches /s.version\s+= Flexunit::VERSION/, content
        assert_matches /s.author\s+= "Your Name"/, content
      end

      assert_file File.join(@temp, 'flexunit.rb') do |content|
        assert_matches /NAME\s+= 'flexunit'/, content
        assert_matches /VERSION\s+= '4.2.pre'/, content
      end
    end

  end
end

