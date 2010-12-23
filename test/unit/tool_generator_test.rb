require 'test_helper'

require 'sprout/generators/tool/tool_generator'

class ToolGeneratorTest < Test::Unit::TestCase
  include SproutTestHelper

  context "A generated tool" do

    setup do
      @temp = File.join(fixtures, 'generators', 'tool')
      FileUtils.mkdir_p @temp
      @generator = Sprout::ToolGenerator.new
      @generator.path = @temp
      @generator.logger = StringIO.new
    end

    teardown do
      remove_file @temp
    end

    should "generate a new tool project" do
      @generator.input = 'flex4sdk'
      @generator.author = 'Some Body'
      @generator.execute

      project = File.join(@temp, 'flex4sdk')
      assert_file project
      assert_file File.join(project, 'Gemfile')
      assert_file File.join(project, 'flex4sdk.gemspec') do |content|
        assert_matches /s.name\s+= Flex4sdk::NAME/, content
        assert_matches /s.version\s+= Flex4sdk::VERSION::STRING/, content
        assert_matches /s.author\s+= "Some Body"/, content
      end
      assert_file File.join(project, 'flex4sdk.rb') do |content|
        assert_matches /NAME = 'flex4sdk'/, content
        assert_matches /url\s+= "http:\/\/github.com/, content
      end
    end

  end
end

